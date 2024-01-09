import chromadb

#Llama standard
from llama_index import VectorStoreIndex, SimpleDirectoryReader, ServiceContext
from llama_index.readers import SimpleWebPageReader
from llama_index.vector_stores import ChromaVectorStore
from llama_index.storage.storage_context import StorageContext

#OpenAI Agent
from llama_index.llms import OpenAI

#JSON mode
import json
from llama_index.prompts import ChatPromptTemplate, ChatMessage

#Pydantic model
from pydantic import BaseModel, Field
from typing import List

#zmq
import zmq
import time

from dotenv import load_dotenv
load_dotenv()
import os

def convert_to_str(value: str | None) -> str:
    return value if value is not None else "Default Value"

os.environ["OPENAI_API_KEY"] = convert_to_str(os.getenv("API_KEY"))

# new lesson generation
# def generate_lesson_stream(source):
#     context = zmq.Context()
#     socket = context.socket(zmq.REQ)
#     socket.connect("tcp://127.0.0.1:5555")
    
#     start_time = time.time()
#     prompt = "Can you make a markdown format lesson based on this source: " + source

#     response = client.chat.completions.create(
#         stream = True,
#         # model="gpt-4-1106-preview",
#         model = "gpt-3.5-turbo",
#         messages = [
#             {"role": "system", "content": "You are a college teacher."},
#             {"role": "user", "content": prompt}
#         ]
#     )
#     # create variables to collect the stream of chunks
#     collected_chunks = []
#     collected_messages = []
#     # iterate through the stream of events
#     for chunk in response:
#         try:
#             chunk_time = time.time() - start_time  # calculate the time delay of the chunk
#             collected_chunks.append(chunk)  # save the event response
#             chunk_message = chunk.choices[0].delta.content # extract the message
#             collected_messages.append(chunk_message)  # save the message
#             # print(f"Message received {chunk_time:.2f} seconds after request: {chunk_message}")  # print the delay and text

#             socket.send_string(chunk_message)
#             print(f"Sent to Rust: {chunk_message}")

#             # Wait for acknowledgment from Rust
#             ack = socket.recv_string()
#             print(f"Received ACK from Rust: {ack}")
#         except Exception as e:
#             print(f"Error processing chunk: {e}")
    
#     # for i in range(25):
#     #     time.sleep(0.25)
#     #     socket.send_string("e")
#     #     print(f"Sent to Rust: e")

#     #     # Wait for acknowledgment from Rust
#     #     ack = socket.recv_string()
#     #     print(f"Received ACK from Rust: {ack}")
        
#     print(f"Finished generation.")
     
#     # Send a finish message
#     socket.send_string("[LL_END_STREAM]")
#     print(f"Sent to Rust: Exit message")
    
#     # Wait for acknowledgment from Rust
#     ack = socket.recv_string()
#     print(f"Received exit ACK from Rust: {ack}")
    
#     socket.close()
#     context.term()
    
class LessonModel(BaseModel):
    """Data model for a lesson."""
    lesson_section_names: List[str] = Field(
        description="Names for various sections of a lesson. Does not include the lesson content."
    )
    references: List[str] = Field(description="All references used in the lesson.")

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
    index = VectorStoreIndex.from_documents(
        documents, storage_context=storage_context
    )

    print(index)
    
def generate_lesson_model(lesson_specifications: list[str], index_path: str):
    # initialize client
    db = chromadb.PersistentClient(path=index_path+"/index/chroma_db")

    # get collection
    chroma_collection = db.get_or_create_collection("content")

    # assign chroma as the vector_store to the context
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    llm = OpenAI(model="gpt-4-1106-preview")
    service_context = ServiceContext.from_defaults(llm=llm)
    
    # load your index from stored vectors
    index = VectorStoreIndex.from_vector_store(
        vector_store, storage_context=storage_context, service_context=service_context
    )
    
    prompt = ChatPromptTemplate(
        message_templates=[
            ChatMessage(
                role="system",
                content=(
                    "You are a Lesson Generator. You will be given data to generate the lesson section names."
                    "Do not generate the content.\n\n"
                    
                    "Generate a valid JSON in the following format:\n"
                    "{json_example}"
                ),
            ),
            # Lesson Specs
            ChatMessage(
                role="user",
                content=(
                    "Here is the Lesson Specifications: \n"
                    "------\n"
                    "{lesson_specifications}\n"
                    "------"
                ),
            ),
        ]
    )
    
    dict_example = {
        "lesson_section_names": ["Introduction", "Sample Section"],
        "references": ["Book A", "Book B"]
    }
    
    json_example = json.dumps(dict_example)

    # lesson_title = "Proxy Design Pattern"
    # focus_topic = "Make the lesson focus about how to create the Proxy Design Pattern and how the concepts can be applied to other design patterns."
    
    messages = prompt.format_messages(
        json_example=json_example, lesson_specifications=lesson_specifications
    )
    
    
    query_engine = index.as_query_engine(
        messages=messages,
        output_cls=LessonModel, 
        response_mode="compact"
    )
    
    
    lesson_model = query_engine.query(
        '''
        Generate the lesson model based on my specifications and the stored in the index. 
        Make sure that the lesson section names generated are extensive and fully covers all available knowledge given
        to you. The same goes for references. Make it extensive, but make sure the references are relevant to the lesson.
        
        Make sure that the lesson names are well structured and contains all the usual sections a lesson might have.
        ''')
    return lesson_model
    
    
def main_context_query(lesson_specifications: list[str], index_path: str):
    context = zmq.Context()
    socket = context.socket(zmq.REQ)
    socket.connect("tcp://127.0.0.1:5555")
    
    # initialize client
    db = chromadb.PersistentClient(path=index_path+"/index/chroma_db")

    # get collection
    chroma_collection = db.get_or_create_collection("content")

    # assign chroma as the vector_store to the context
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    llm = OpenAI(model="gpt-4-1106-preview")
    service_context = ServiceContext.from_defaults(llm=llm)
    
    prompt = ChatPromptTemplate(
        message_templates=[
            # Lesson Specs
            ChatMessage(
                role="user",
                content=(
                    "Here is the Lesson Specifications: \n"
                    "------\n"
                    "{lesson_specifications}\n"
                    "------"
                ),
            ),
        ]
    )
    
    
    messages = prompt.format_messages(
        lesson_specifications=lesson_specifications
    )
    
    messages=messages,
    # load your index from stored vectors
    index = VectorStoreIndex.from_vector_store(
        vector_store, storage_context=storage_context, service_context=service_context
    )
    
    query_engine = index.as_query_engine(
        messages=messages,
        streaming=True, 
        verbose=True,
        # response_mode="refine"
    )

    lesson_model = generate_lesson_model(lesson_specifications=lesson_specifications, index_path=index_path)
    print(lesson_model)

    for section in lesson_model.lesson_section_names:
        response_stream = query_engine.query(
            f'''
            Create the lesson section based on the given section name: {section}. 
            Include the section name in the beginning of the output.
            
            Ensure that the output goes like this format:
            
            # [Section name]
            
            [Section content...]
            
            Note: Don't actually output this. This is just an example. Only the format should be followed.
            Note: Do not include References.
            ''',
        )
        response_gen = response_stream.response_gen

        for token in response_gen:
            # pass these through zmq
            socket.send_string(token)
            # Wait for acknowledgment from Rust
            socket.recv_string()
            
        socket.send_string("\n")
        # Wait for acknowledgment from Rust
        socket.recv_string()
    
    socket.send_string("[LL_END_STREAM]")
    print(f"Sent to Rust: Exit message")
    
    # Wait for acknowledgment from Rust
    ack = socket.recv_string()
    print(f"Received exit ACK from Rust: {ack}")
    
    socket.close()
    context.term()
    # TODO: Handle references later
    
    
def rust_callback(lesson_specifications: list[str], index_path: str, files: list[str] = [], urls: list[str] = []):
    generate_content_index(files=files, urls=urls, index_path=index_path)
    main_context_query(lesson_specifications=lesson_specifications, index_path=index_path)
    
# rust_callback(
#     lesson_specifications=[
#         "Title - Proxy Design Pattern",
#         "Focus Topic - How to implement Proxy Design Pattern"
#     ],
#     index_path="./",
#     # files=["C:/Users/karlj/OneDrive/Documents/Proxy Design Pattern Summary.pdf"], 
#     urls=["https://en.wikipedia.org/wiki/Proxy_pattern"]
# )


