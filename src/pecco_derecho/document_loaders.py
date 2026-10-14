import os
import uuid
import tempfile
from pathlib import Path
from langchain_community.document_loaders import (
    TextLoader,
    WebBaseLoader,
    DirectoryLoader,
    PyPDFLoader
)

from openai import OpenAI
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct

from dotenv import load_dotenv

load_dotenv()

qdrant_client = QdrantClient(host='localhost', port=6333)

qdrant_client.create_collection(
    collection_name='documents',
    vectors_config=VectorParams(size=1536, distance=Distance.COSINE)
)

openai_client = OpenAI()

ROOT = Path(__file__).resolve().parents[2]

pdf_path = ROOT / "docs" / "rag-fundamentals-interview-guide.pdf"

def load_text_file():
    print(os.__file__)
    with tempfile.NamedTemporaryFile(delete=False, suffix=".txt") as temp_file:
        temp_file.write(b"Hello, this is a sample text file.\nThis file is used to demonstrate the TextLoader.")
        temp_file_path = temp_file.name

    try:
        loader = TextLoader(temp_file_path)
        documents = loader.load()

        print(f"Loaded {len(documents)} document(s)")
        print(f"Content preview: {documents[0].page_content[:100]}...")
        print(f"Metadata {documents[0].metadata}")

        # for doc in documents:
        #     print("Document Content:")
        #     print(doc)
        #     print(doc.page_content)

    finally:
        os.remove(temp_file_path)

def pdf_loader(pdf_path: str):
    loader = PyPDFLoader(pdf_path)
    documents = loader.load()

    print (f"Loaded {len(documents)} document(s) from PDF")

    for i, doc in enumerate(documents):
        print(f"Document {i+1} Content Preview: {doc.page_content[:100]}")
        print(f"Metadata: {doc.metadata}")
    return documents

def doc_embedding(docs: list):
    doc_embeddings = [openai_client.embeddings.create(input=doc, model='text-embedding-3-small').data[0].embedding for doc in docs]
    qdrant_client.upsert(
        collection_name='documents',
        wait=True,
        points=[
            PointStruct(
                id=uuid.uuid4(),
                vector=doc_embeddings[i], 
                payload={'document': doc_embeddings[i], 'type': 'RAG'}
            ) for i in range(len(doc_embeddings))
        ]
    )

    query_embedding = openai_client.embeddings.create(input='something random about AI', model='text-embedding-3-small').data[0].embedding

    results = qdrant_client.query_points(
        collection_name='documents',
        query=query_embedding,
        with_payload=True,
        limit=3
    ).points

    print(results)

if __name__ == "__main__":
    # load_text_file()
    docs = pdf_loader(pdf_path)