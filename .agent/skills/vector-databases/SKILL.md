---
name: Vector Databases
description: "Cấu trúc cơ sở dữ liệu Vector, truy vấn ngữ nghĩa AI và mô hình tối ưu truy RAG."
category: Database & AI/ML
difficulty: Advanced
last_updated: 2026-01-16
---

# Vector Databases

Expert patterns for vector databases, semantic search, và AI/ML integration.

---

## When to Use This Skill

- Semantic search applications
- RAG (Retrieval-Augmented Generation)
- Recommendation systems
- Image/video similarity search
- LLM knowledge bases
- AI-powered applications

---

## Quick Reference

### Vector Database Decision Tree

```
Choose Vector Database:

Need managed cloud service?
├── YES → Pinecone (fully managed)
├── NO → Self-hosted?
    ├── Open source → Weaviate, Milvus
    └── PostgreSQL extension → pgvector
```

---

### Pinecone Example

```python
import pinecone
from openai import OpenAI

# Initialize
pinecone.init(api_key="your-api-key", environment="us-west1-gcp")

# Create index
pinecone.create_index(
    name="documents",
    dimension=1536,  # OpenAI embedding dimension
    metric="cosine"
)

index = pinecone.Index("documents")

# Generate embeddings
client = OpenAI()

def get_embedding(text):
    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=text
    )
    return response.data[0].embedding

# Insert vectors
texts = [
    "Python is a programming language",
    "JavaScript runs in browsers",
    "Docker containerizes applications"
]

vectors = [
    (f"doc-{i}", get_embedding(text), {"text": text})
    for i, text in enumerate(texts)
]

index.upsert(vectors=vectors)

# Query
query = "What is a programming language?"
query_embedding = get_embedding(query)

results = index.query(
    vector=query_embedding,
    top_k=3,
    include_metadata=True
)

for match in results.matches:
    print(f"Score: {match.score}, Text: {match.metadata['text']}")
```

---

### Weaviate Example

```python
import weaviate
from weaviate.classes.init import Auth

# Initialize
client = weaviate.connect_to_local()

# Create schema
schema = {
    "class": "Document",
    "vectorizer": "text2vec-openai",
    "properties": [
        {"name": "title", "dataType": ["text"]},
        {"name": "content", "dataType": ["text"]}
    ]
}

client.schema.create_class(schema)

# Insert data
client.data_object.create(
    class_name="Document",
    data_object={
        "title": "Python Tutorial",
        "content": "Python is a high-level programming language"
    }
)

# Semantic search
result = client.query.get(
    "Document",
    ["title", "content"]
).with_near_text({
    "concepts": ["programming language"]
}).with_limit(3).do()

print(result)
```

---

### pgvector (PostgreSQL Extension)

```sql
-- Install extension
CREATE EXTENSION vector;

-- Create table
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536)
);

-- Create index
CREATE INDEX ON documents 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Insert
INSERT INTO documents (content, embedding)
VALUES ('Python tutorial', '[0.1, 0.2, ...]');

-- Similarity search
SELECT content, 
       1 - (embedding <=> '[0.1, 0.2, ...]') AS similarity
FROM documents
ORDER BY embedding <=> '[0.1, 0.2, ...]'
LIMIT 5;
```

---

### RAG (Retrieval-Augmented Generation)

```python
from langchain.vectorstores import Pinecone
from langchain.embeddings import OpenAIEmbeddings
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA

# Setup vector store
embeddings = OpenAIEmbeddings()
vectorstore = Pinecone.from_existing_index(
    index_name="documents",
    embedding=embeddings
)

# Setup QA chain
llm = ChatOpenAI(model="gpt-4")
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3})
)

# Query
question = "What is Python?"
answer = qa_chain.run(question)
print(answer)
```

---

### Hybrid Search (Vector + Keyword)

```python
# Weaviate hybrid search
result = client.query.get(
    "Document",
    ["title", "content"]
).with_hybrid(
    query="Python programming",
    alpha=0.5  # 0 = keyword only, 1 = vector only
).with_limit(5).do()
```

---

### Chunking Strategies

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Split large documents
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", " ", ""]
)

chunks = text_splitter.split_text(long_document)

# Store each chunk
for i, chunk in enumerate(chunks):
    embedding = get_embedding(chunk)
    index.upsert(vectors=[(f"chunk-{i}", embedding, {"text": chunk})])
```

---

### Distance Metrics

```python
# Cosine similarity (most common)
pinecone.create_index(name="index", metric="cosine")

# Euclidean distance
pinecone.create_index(name="index", metric="euclidean")

# Dot product
pinecone.create_index(name="index", metric="dotproduct")
```

---

### Performance Optimization

```python
# Batch upserts (Pinecone)
batch_size = 100
for i in range(0, len(vectors), batch_size):
    batch = vectors[i:i + batch_size]
    index.upsert(vectors=batch)

# Namespaces for multi-tenancy
index.upsert(
    vectors=vectors,
    namespace="user-123"
)

results = index.query(
    vector=query_embedding,
    namespace="user-123",
    top_k=5
)
```

---

### Metadata Filtering

```python
# Filter by metadata
results = index.query(
    vector=query_embedding,
    filter={
        "category": {"$eq": "technology"},
        "year": {"$gte": 2020}
    },
    top_k=5,
    include_metadata=True
)
```

---

## Best Practices

✅ **Chunk wisely** - Balance context vs. precision  
✅ **Use metadata** - Enable filtering, improve relevance  
✅ **Batch operations** - Better performance  
✅ **Monitor costs** - Vector storage can be expensive  
✅ **Hybrid search** - Combine vector + keyword  
✅ **Cache embeddings** - Don't regenerate  
✅ **Version embeddings** - Track model changes

---

## Anti-Patterns

❌ **Too large chunks** → Loss of precision  
❌ **Too small chunks** → Loss of context  
❌ **No metadata** → Cannot filter  
❌ **Regenerating embeddings** → Expensive  
❌ **Single metric for all** → Choose appropriate distance  
❌ **No monitoring** → Cost surprises

---

## Related Skills

- `api-patterns` - API design for search
- `nosql-patterns` - Database patterns
- `microservices-communication` - Service integration

---

## Official Resources

- [Pinecone Documentation](https://docs.pinecone.io/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [pgvector GitHub](https://github.com/pgvector/pgvector)
- [LangChain Vectorstores](https://python.langchain.com/docs/modules/data_connection/vectorstores/)
