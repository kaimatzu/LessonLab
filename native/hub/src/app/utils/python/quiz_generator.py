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
from typing import Annotated, Any, List, Union, Literal

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
    question: str = Field(description="The question")
    choices: List[ChoiceModel] = Field(description="Four choices for the multiple choice question type. And only one of them is correct")

class IdentificationQuestionModels(BaseModel):
    """Data model that holds a list of identifiation question model"""
    questions: List[IdentificationQuestionModel] = Field(description="List of identification question models")

class MultipleChoiceQuestionModels(BaseModel):
    """Data model that holds a list of multiple choice question model"""
    questions: List[MultipleChoiceQuestionModel] = Field(description="List of multiple choice question models")

class QuestionsModels:
    questions: List[Union[IdentificationQuestionModel, MultipleChoiceQuestionModel]] = Field(description="List of questions")


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
                        "Make sure you follow the following instructions.Make sure to make the answer concise."
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

    response = output.response
    print(f">>> output: {output}")
    print("\n\n")
    print(f">>> response: {response}")
    print("\n\n")

    # print(f"output: {output.question}")
    # print(f"response: {response.question}")

    # output_dict = output.dict()
    # memory.append(response)

    return output



def generate_identification(quiz_specifications: list[str], index: VectorStoreIndex, existing_questions: list[str]):
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
                        "Make sure you follow the following instructions.Make sure to make the answer concise."
                        "Make sure to always end the question with a question mark. Don't ask questions about the source. Do not mention the references or the documents provided. Don't include the questions about who prepared the document."
                        "Make sure to follow the number of questions in the quiz specifications."
                        "Make sure to make the answer short and concise."

                        "Generate a valid JSON in the following format:\n"
                        "{json_example}\n"
                        "Take note this is only an example the user might want to have more questions.\n"

                        "Do not generate existing questions or similar questions below if there are questions after this line:\n"
                        "{existing_questions}\n"
                        "Do not generate the existing questions above if there are any because you are a question generator for a quiz and you don't want to generate the same questions multiple times in the same quiz\n"
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

    messages = prompt.format_messages(json_example=json_example,
                                      quiz_specifications=quiz_specifications,
                                      existing_questions=existing_questions)

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

    response = output.response
    print(f">>> output: {output}")
    print("\n\n")
    print(f">>> response: {response}")
    print("\n\n")

    # print(f"output: {output.question}")
    # print(f"response: {response.question}")

    # output_dict = output.dict()
    # memory.append(response)

    return output



def generate_multiple_choice(quiz_specifications: list[str], index: VectorStoreIndex, existing_questions: list[str]):
    dict_example = {
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

    json_example = json.dumps(dict_example)

    prompt = ChatPromptTemplate(message_templates=[
        ChatMessage(role="system",
                    content=(
                        "You are a question generator. You will be given data to generate the questions."
                        "You are to generate technical question about the given topic along with 4 choices one of which is correct.\n"
                        "Make sure to follow the number of questions in the quiz specifications."
                        "Don't ask questions about the source."

                        "Generate a valid JSON in the following format:\n"
                        "{json_example}\n"
                        "Take not this is just an example the user may want more questions."

                        "Do not generate these questions if there are questions after this line:\n"
                        "{existing_questions}"
                        "Do not generate the existing questions above if ther are any because you are a question generator for a quiz and you don't want to generate the same questions multiple times in the same quiz\n"
                        "Make sure each question are unique."
                    )),
        ChatMessage(role="user",
                    content=(
                        "Here is the lesson specifications: \n"
                        "------\n"
                        "{quiz_specifications}\n"
                        "------"
                    )),
    ])

    # memory = []

    messages = prompt.format_messages(json_example=json_example,
                                      quiz_specifications=quiz_specifications,
                                      existing_questions=existing_questions)

    query_engine = index.as_query_engine(messages=messages,
                                         output_cls=MultipleChoiceQuestionModel,
                                         repsonse_mode="compact")

    output = query_engine.query(
        '''
        Generate the question based on the quiz specifications
        '''
    )


    output_dict = output.dict()
    string = f"question: {output.question}, answer: {output.answer}"
    # memory.append(string)

    return output



def generate_question(quiz_specifications: list[str],
                      index: VectorStoreIndex,
                      type: int,
                      existing_questions: list[str]):
    if type == 0:
        return generate_identification(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    elif type == 1:
        return generate_multiple_choice(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
    else:
        random_choice = random.choice([True, False])
        if random_choice:
            return generate_identification(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)
        else:
            return generate_multiple_choice(quiz_specifications=quiz_specifications, index=index, existing_questions=existing_questions)



def generate_answer(question: str,index: VectorStoreIndex):
    
    prompt = ChatPromptTemplate(message_templates=[
        ChatMessage(role="system",
                    content=(
                        "You are a question and answer system."
                    )),
    ])


    messages = prompt.format_messages()
    query_engine = index.as_query_engine(messages=messages, response_mode="compact")

    output = query_engine.query(
        f'''
        {question}
        '''
    )

    return output



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
    
    existing_questions = []

    #for _ in range(num_of_questions):
        
    questions = generate_question(quiz_specifications=quiz_specifications,
                                  index=index,
                                  existing_questions=existing_questions,
                                  type=type)
        # answer = generate_answer(question=question.question, index=index)
        

        # print(f"existing question: {question.question}")
    # existing_questions.append(question)
    # questions.append(question)
        # answers.append(answer)
    print(questions)

    # for i in range(num_of_questions):
    #     print(f"question: {questions}")
    #     # print(f"answer: {questions[i]}")

    return questions



def rust_callback(quiz_specifications: list[str], index_path: str, files: list[str] = [], urls: list[str] = []):
    generate_content_index(files=files, urls=urls, index_path=index_path)
    # 0 - identifciation
    # 1 - multiple choice
    # 2 - random
    output = generate_questions(quiz_specifications=quiz_specifications, index_path=index_path, num_of_questions=10, type=0)
    return output.response.json()
    # print(output)



def run():
    quiz_specs: list[str] = [
        "Title: Turing Machine\n",
        "Focus Topic: Turing Machine\n",
        "Difficulty: Hard\n",
        "Number of questions: 10\n"
    ]
    # "Number of Questions: 10\n",
    # "Timeframe: 10 minutes\n",
    # "Type: Identification\n"

    index_path = '.'

    files: list[str] = ["E:/School/Automata Theory/Turing Machine.pdf"]

    rust_callback(quiz_specifications=quiz_specs, index_path=index_path, files=files, urls=[])
