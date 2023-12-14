import chromadb
from llama_index import VectorStoreIndex, SimpleDirectoryReader
from llama_index.readers import SimpleWebPageReader
from llama_index.vector_stores import ChromaVectorStore
from llama_index.storage.storage_context import StorageContext
from dotenv import load_dotenv
load_dotenv()
import os

load_dotenv()
import os

def convert_to_str(value: str | None) -> str:
    return value if value is not None else "Default Value"

os.environ["OPENAI_API_KEY"] = convert_to_str(os.getenv("API_KEY"))

def generate_index(files: list[str], urls: list[str], storage_path: str):
    documents = SimpleDirectoryReader(input_files=files).load_data()
    documents += SimpleWebPageReader(html_to_text=True).load_data(urls=urls)
    
    # initialize client, setting path to save data
    db = chromadb.PersistentClient(path=storage_path + "/chroma_db") # TODO: Change path to local

    # create collection
    chroma_collection = db.get_or_create_collection("quickstart")

    # assign chroma as the vector_store to the context
    vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    # create your index
    VectorStoreIndex.from_documents(
        documents, storage_context=storage_context
    )