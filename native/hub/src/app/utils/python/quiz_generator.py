import chromadb

#Llama standard
from llama_index import Document, VectorStoreIndex, SimpleDirectoryReader, ServiceContext
from llama_index.readers import SimpleWebPageReader
from llama_index.vector_stores import ChromaVectorStore
from llama_index.storage.storage_context import StorageContext
from llama_index.response.schema import RESPONSE_TYPE

#OpenAI Agent
from llama_index.llms import OpenAI

#JSON mode
import json
from llama_index.prompts import ChatPromptTemplate, ChatMessage

#Pydantic model
from pydantic import BaseModel, Field, Tag, Discriminator
from typing import Annotated, Any, List, Literal, Union

#zmq
import zmq
import time

#Pydantic
from llama_index.program import OpenAIPydanticProgram

import random

from dotenv import load_dotenv
load_dotenv()
import os

def convert_to_str(value: str | None) -> str:
    return value if value is not None else "Default Value"

os.environ["OPENAI_API_KEY"] = convert_to_str(os.getenv("API_KEY"))

class ChoiceModel(BaseModel):
    """Represents a choice for a multiple choice model"""
    content: str = Field(description="The content of the choice")
    is_correct: bool = Field(description="Boolean to determine wether the choice is correct.")

class IdentificationQuestionModel(BaseModel):
    """Data model for identification question"""
    question: str = Field(description="The question")
    answer: str = Field(description="The correct answer to the question")

class MultipleChoiceQuestionModel(BaseModel):
    """Data model for multiple choice question"""
    question:str = Field(description="The question")
    choices: List[ChoiceModel] = Field(description="Four choices for the multiple choice question type. And only one of them is correct")

class IdentificationQuestionModels(BaseModel):
    """Data model that holds a list of identifiation question model"""
    questions: List[IdentificationQuestionModel] = Field(description="List of identification question models")

class MultipleChoiceQuestionModels(BaseModel):
    """Data model that holds a list of multiple choice question model"""
    questions: List[MultipleChoiceQuestionModel] = Field(description="List of multiple choice question models")
    
class Both(BaseModel):
    """Data model that holds both list of questions"""
    identification: IdentificationQuestionModel = Field(description="Identification question model")
    multiple_choice: MultipleChoiceQuestionModel = Field(description="Multiple choice question model")

class QuestionsModels(BaseModel):
    """Data model that holds list of questions"""
    # questions: List[Both] = Field(description="List of both question type")
    identification: List[IdentificationQuestionModel] = Field(description="List of identification questions")
    multiple_choice: List[MultipleChoiceQuestionModel] = Field(description="List of multiple choice questions")




def generate_content_index(files: list[str], urls: list[str], index_path: str):
    documents = []
    # load some documents
    if files:
        documents += SimpleDirectoryReader(input_files=files).load_data()
    if urls:
        documents += SimpleWebPageReader(html_to_text=True).load_data(urls=urls)
    
    # initialize client, setting path to save data
    db = chromadb.PersistentClient(path=index_path+"/index/chroma_db")

    # create collection
    chroma_collection = db.get_or_create_collection("content")

    # assign chroma as the vector_store to the context
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    # create your index
    index = VectorStoreIndex.from_documents(documents,
                                            storage_context=storage_context)

    print(index)


def generate_both(quiz_specifications: list[str], index: VectorStoreIndex):
    dict_example = {
        "identification": [
            {
                "identification": {
                    "type": "identification",
                    "question" : "Who invented the telephone?",
                    "answer" : "Alexander Bell"
                }
            }
        ],
        "multiple_choice": [
            {
                "type": "multiple_choice",
                "question" : "Who invented the telephone?",
                "choices": [
                    {
                        "content": "Isaac Newton",
                        "is_correct": "false"
                    },
                    {
                        "content": "Alexander Bell",
                        "is_correct": "true"
                    },
                    {
                        "content": "Alexander Hamilton",
                        "is_correct": "false"
                    },
                    {
                        "content": "Albert Einstein",
                        "is_correct": "false"
                    },
                ]
            }
        ]

    }

    json_example = json.dumps(dict_example)

    prompt = ChatPromptTemplate(message_templates=[
        ChatMessage(role="system",
                    content=(
                        "You are a quiz generator. You will be given topic to generate the questions."
                        "You are to generate multiple choice questions and identification questions."
                        "If it is an identification question you are to generate a technical question along with the correct answer about the given topic."
                        "If it is a multiple choice you are to generate a technical question about the given topic along with 4 choices one of which is correct."
                        "You will generate a technical question along with the correct answer about the given topic."
                        "Make sure you follow the following instructions. Make sure to make the answer concise."
                        "Make sure to always end the question with a question mark. Don't ask questions about the source. Do not mention the references or the documents provided. Don't include the questions about who prepared the document."
                        "Make sure to follow the number of questions in the quiz specifications."
                        "Make sure to make the answer short and concise."

                        "Generate a valid JSON in the following format:\n"
                        "{json_example}\n"
                        "Take note this is only an example the user might want to have more questions.\n"
                        "Take note this is only an example the might want to have identification only or multiple choice only or both so follow the user's quiz specs.\n"

                        "Make sure each question are unique"
                        "Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase"
                    )),
        ChatMessage(role="user",
                    content=(
                        "Here is the quiz specifications: \n"
                        "------\n"
                        "{quiz_specifications}\n"
                        "------"
                        "I want you to follow these specifications"
                    )),
    ])

    messages = prompt.format_messages(json_example=json_example, quiz_specifications=quiz_specifications)

    query_engine = index.as_query_engine(messages=messages,
                                         output_cls=QuestionsModels,
                                         repsonse_mode="accumulate")
    
    try:
        output = query_engine.query(
            '''
            Generate the question based on my specifications.
            Make sure each question are unique
            Make sure to not ask question about the sources/documents provided
            Make sure to ask technical questions about the focus topic specification
            Make sure to follow the number of questions in my specifications
            Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase
            '''
        )
    except Exception as e:
        print(f"Error: {e}")


    # response = output.response
    # print(f">>> output: {output}")
    # print("\n\n")
    # print(f">>> response: {response}")
    # print("\n\n")

    # print(f"output: {output.question}")
    # print(f"response: {response.question}")

    # output_dict = output.dict()
    # memory.append(response)

    return output



def generate_identification(quiz_specifications: list[str], index: VectorStoreIndex):
    dict_example = {
        "questions": [
            {
                "question" : "Who invented the telephone?",
                "answer" : "Alexander Bell"
            },
            {
                "question" : "Who invented the atomic bomb?",
                "answer" : "Robert Oppenheimer"
            }
        ]
    }

    json_example = json.dumps(dict_example)

    prompt = ChatPromptTemplate(message_templates=[
        ChatMessage(role="system",
                    content=(
                        "You are a quiz generator. You will be given topic to generate the questions."
                        "You will generate a technical question along with the correct answer about the given topic."
                        "Make sure you follow the following instructions. Make sure to make the answer concise."
                        "Make sure to always end the question with a question mark. Don't ask questions about the source. Do not mention the references or the documents provided. Don't include the questions about who prepared the document."
                        "Make sure to follow the number of questions in the quiz specifications."
                        "Make sure to make the answer short and concise."

                        "Generate a valid JSON in the following format:\n"
                        "{json_example}\n"
                        "Take note this is only an example the user might want to have more questions.\n"

                        "Make sure each question are unique"
                        "Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase"
                    )),
        ChatMessage(role="user",
                    content=(
                        "Here is the quiz specifications: \n"
                        "------\n"
                        "{quiz_specifications}\n"
                        "------"
                        "I want you to follow these specifications"
                    )),
    ])

    messages = prompt.format_messages(json_example=json_example, quiz_specifications=quiz_specifications)

    query_engine = index.as_query_engine(messages=messages,
                                         output_cls=IdentificationQuestionModels,
                                         repsonse_mode="accumulate")
    
    output = query_engine.query(
        '''
        Generate the question based on my specifications.
        Make sure each question are unique
        Make sure to not ask question about the sources/documents provided
        Make sure to ask technical questions about the focus topic specification
        Make sure to follow the number of questions in my specifications
        Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase
        '''
    )

    # response = output.response
    # print(f">>> output: {output}")
    # print("\n\n")
    # print(f">>> response: {response}")
    # print("\n\n")

    # print(f"output: {output.question}")
    # print(f"response: {response.question}")

    # output_dict = output.dict()
    # memory.append(response)

    return output



def generate_multiple_choice(quiz_specifications: list[str], index: VectorStoreIndex):
    dict_example = {
        "questions": [
            {
                "question" : "Who invented the telephone?",
                "choices": [
                    {
                        "content": "Isaac Newton",
                        "is_correct": "false"
                    },
                    {
                        "content": "Alexander Bell",
                        "is_correct": "true"
                    },
                    {
                        "content": "Alexander Hamilton",
                        "is_correct": "false"
                    },
                    {
                        "content": "Albert Einstein",
                        "is_correct": "false"
                    },
                ]
            }
        ]
    }

    json_example = json.dumps(dict_example)

    prompt = ChatPromptTemplate(message_templates=[
        ChatMessage(role="system",
                    content=(
                        "You are a quiz generator. You will be given topic to generate the questions."
                        "You are to generate technical question about the given topic along with 4 choices one of which is correct.\n"
                        "Make sure you follow the following instructions. Make sure to make the answer concise."
                        "Make sure to always end the question with a question mark. Don't ask questions about the source. Do not mention the references or the documents provided. Don't include the questions about who prepared the document."
                        "Make sure to follow the number of questions in the quiz specifications."
                        "Don't ask questions about the source."

                        "Generate a valid JSON in the following format:\n"
                        "{json_example}\n"
                        "Take not this is just an example the user may want more questions."

                        "Make sure each question are unique."
                        "Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase"
                    )),
        ChatMessage(role="user",
                    content=(
                        "Here is the quiz specifications you must strictly follow: \n"
                        "------\n"
                        "{quiz_specifications}\n"
                        "------"
                    )),
    ])

    # memory = []

    messages = prompt.format_messages(json_example=json_example, quiz_specifications=quiz_specifications)

    query_engine = index.as_query_engine(messages=messages,
                                         output_cls=MultipleChoiceQuestionModels,
                                         repsonse_mode="accumulate")

    output = query_engine.query(
        '''
        Generate the question based on my specifications.
        Make sure each question are unique
        Make sure to not ask question about the sources/documents provided
        Make sure to ask technical questions about the focus topic specification
        Make sure to follow the number of questions in my specifications
        Do not make a lengthy sentence answer, make the answer short and concise like a word, term, or a phrase
        '''
    )


    # output_dict = output.dict()
    # string = f"question: {output.question}, answer: {output.answer}"
    # memory.append(string)

    return output



def generate_question(quiz_specifications: list[str], index: VectorStoreIndex):

    if "Identification" in quiz_specifications[2]:
        return generate_identification(quiz_specifications=quiz_specifications, index=index)
    elif "Multiple" in quiz_specifications[2]:
        return generate_multiple_choice(quiz_specifications=quiz_specifications, index=index)
    else:
        return generate_both(quiz_specifications=quiz_specifications, index=index)

    # return generate_both(quiz_specifications=quiz_specifications, index=index)
    # return generate_identification(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    # if type == 0:
    #     return generate_identification(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    # elif type == 1:
    #     return generate_multiple_choice(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    # else:
    #     random_choice = random.choice([True, False])
    #     if random_choice:
    #         return generate_identification(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    #     else:
    #         return generate_multiple_choice(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)



def generate_questions(quiz_specifications: list[str], index_path: str, num_of_questions: int, type: int):
    db = chromadb.PersistentClient(path=index_path+"/index/chroma_db")

    # get collection
    chroma_collection = db.get_or_create_collection("content")

    # assign chroma as the vector_store to the context
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    llm = OpenAI(model="gpt-4-1106-preview")
    service_context = ServiceContext.from_defaults(llm=llm)
    
    # load your index from stored vectors
    index = VectorStoreIndex.from_vector_store(vector_store,
                                               storage_context=storage_context,
                                               service_context=service_context)
    
        
    questions = generate_question(quiz_specifications=quiz_specifications, index=index)
        
    response = questions.response

    return response



def rust_callback(quiz_specifications: list[str], index_path: str, files: list[str] = [], urls: list[str] = []):
    generate_content_index(files=files, urls=urls, index_path=index_path)
    output = generate_questions(quiz_specifications=quiz_specifications, index_path=index_path, num_of_questions=10, type=2)
    return output.json()



def run():
    quiz_specs: list[str] = [
        "Title: Turing Machine\n",
        "Focus Topic: Turing Machine\n",
        "Difficulty: Hard\n",
        "Number of questions: 10\n",
        "Type: Both\n"
    ]
    # "Number of Questions: 10\n",
    # "Timeframe: 10 minutes\n",
    # "Type: Identification\n"

    index_path = '.'

    files: list[str] = ["E:/School/Automata Theory/Turing Machine.pdf"]

    output = rust_callback(quiz_specifications=quiz_specs, index_path=index_path, files=files, urls=[])