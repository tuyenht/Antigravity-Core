# Vector Databases Expert (Pinecone, Weaviate)

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **Pinecone:** v3.x  
> **Weaviate:** v4.x  
> **Priority:** P0 - Load for AI/RAG projects

---

You are an expert in Vector Databases like Pinecone, Weaviate, and Milvus.

## Core Principles

- Store high-dimensional vectors (embeddings)
- Optimize for similarity search (ANN)
- Support RAG (Retrieval-Augmented Generation)
- Handle metadata filtering

---

## 1) Embedding Fundamentals

### Generating Embeddings
```typescript
// ==========================================
// OPENAI EMBEDDINGS
// ==========================================

import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function getEmbedding(text: string): Promise<number[]> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',  // 1536 dimensions
    input: text,
  });
  
  return response.data[0].embedding;
}

async function getEmbeddings(texts: string[]): Promise<number[][]> {
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: texts,
  });
  
  return response.data.map(d => d.embedding);
}


// ==========================================
// HUGGING FACE EMBEDDINGS (Local)
// ==========================================

import { pipeline } from '@xenova/transformers';

let embeddingPipeline: any = null;

async function getLocalEmbedding(text: string): Promise<number[]> {
  if (!embeddingPipeline) {
    embeddingPipeline = await pipeline(
      'feature-extraction',
      'Xenova/all-MiniLM-L6-v2'  // 384 dimensions
    );
  }
  
  const output = await embeddingPipeline(text, {
    pooling: 'mean',
    normalize: true,
  });
  
  return Array.from(output.data);
}


// ==========================================
// COHERE EMBEDDINGS
// ==========================================

import { CohereClient } from 'cohere-ai';

const cohere = new CohereClient({
  token: process.env.COHERE_API_KEY,
});

async function getCohereEmbeddings(
  texts: string[],
  inputType: 'search_document' | 'search_query'
): Promise<number[][]> {
  const response = await cohere.embed({
    model: 'embed-english-v3.0',  // 1024 dimensions
    texts,
    inputType,
  });
  
  return response.embeddings as number[][];
}
```

### Text Chunking
```typescript
// ==========================================
// CHUNKING STRATEGIES
// ==========================================

interface Chunk {
  text: string;
  index: number;
  metadata: {
    startChar: number;
    endChar: number;
    wordCount: number;
  };
}

// Fixed-size chunking with overlap
function chunkBySize(
  text: string,
  chunkSize: number = 500,
  overlap: number = 50
): Chunk[] {
  const chunks: Chunk[] = [];
  let startIndex = 0;
  let chunkIndex = 0;
  
  while (startIndex < text.length) {
    const endIndex = Math.min(startIndex + chunkSize, text.length);
    const chunkText = text.slice(startIndex, endIndex);
    
    chunks.push({
      text: chunkText,
      index: chunkIndex,
      metadata: {
        startChar: startIndex,
        endChar: endIndex,
        wordCount: chunkText.split(/\s+/).length,
      },
    });
    
    startIndex = endIndex - overlap;
    chunkIndex++;
    
    if (startIndex >= text.length) break;
  }
  
  return chunks;
}


// Semantic chunking (by paragraph/sentence)
function chunkBySentence(
  text: string,
  maxChunkSize: number = 500
): Chunk[] {
  const sentences = text.match(/[^.!?]+[.!?]+/g) || [text];
  const chunks: Chunk[] = [];
  let currentChunk = '';
  let chunkIndex = 0;
  let startChar = 0;
  
  for (const sentence of sentences) {
    if (currentChunk.length + sentence.length > maxChunkSize && currentChunk) {
      chunks.push({
        text: currentChunk.trim(),
        index: chunkIndex,
        metadata: {
          startChar,
          endChar: startChar + currentChunk.length,
          wordCount: currentChunk.split(/\s+/).length,
        },
      });
      chunkIndex++;
      startChar += currentChunk.length;
      currentChunk = sentence;
    } else {
      currentChunk += sentence;
    }
  }
  
  if (currentChunk.trim()) {
    chunks.push({
      text: currentChunk.trim(),
      index: chunkIndex,
      metadata: {
        startChar,
        endChar: startChar + currentChunk.length,
        wordCount: currentChunk.split(/\s+/).length,
      },
    });
  }
  
  return chunks;
}


// Markdown-aware chunking
function chunkMarkdown(
  markdown: string,
  maxChunkSize: number = 1000
): Chunk[] {
  // Split by headers
  const sections = markdown.split(/(?=^#{1,3}\s)/m);
  const chunks: Chunk[] = [];
  let chunkIndex = 0;
  
  for (const section of sections) {
    if (section.length <= maxChunkSize) {
      chunks.push({
        text: section.trim(),
        index: chunkIndex++,
        metadata: {
          startChar: 0,
          endChar: section.length,
          wordCount: section.split(/\s+/).length,
        },
      });
    } else {
      // Further split large sections by paragraph
      const paragraphs = section.split(/\n\n+/);
      let currentChunk = '';
      
      for (const para of paragraphs) {
        if (currentChunk.length + para.length > maxChunkSize && currentChunk) {
          chunks.push({
            text: currentChunk.trim(),
            index: chunkIndex++,
            metadata: {
              startChar: 0,
              endChar: currentChunk.length,
              wordCount: currentChunk.split(/\s+/).length,
            },
          });
          currentChunk = para + '\n\n';
        } else {
          currentChunk += para + '\n\n';
        }
      }
      
      if (currentChunk.trim()) {
        chunks.push({
          text: currentChunk.trim(),
          index: chunkIndex++,
          metadata: {
            startChar: 0,
            endChar: currentChunk.length,
            wordCount: currentChunk.split(/\s+/).length,
          },
        });
      }
    }
  }
  
  return chunks;
}
```

---

## 2) Pinecone

### Client Setup
```typescript
// ==========================================
// PINECONE CLIENT
// ==========================================

import { Pinecone } from '@pinecone-database/pinecone';

const pinecone = new Pinecone({
  apiKey: process.env.PINECONE_API_KEY!,
});

// Get or create index
const indexName = 'documents';
const index = pinecone.index(indexName);

// With namespace (logical partitioning)
const namespace = index.namespace('project-123');


// ==========================================
// INDEX OPERATIONS
// ==========================================

// Create index (one-time)
await pinecone.createIndex({
  name: 'documents',
  dimension: 1536,  // Must match embedding model
  metric: 'cosine',  // 'cosine' | 'euclidean' | 'dotproduct'
  spec: {
    serverless: {
      cloud: 'aws',
      region: 'us-east-1',
    },
  },
});

// List indexes
const indexes = await pinecone.listIndexes();

// Describe index
const description = await pinecone.describeIndex('documents');

// Delete index
await pinecone.deleteIndex('documents');
```

### Upsert and Query
```typescript
// ==========================================
// UPSERT VECTORS
// ==========================================

interface Document {
  id: string;
  content: string;
  title: string;
  url?: string;
  category?: string;
  createdAt: Date;
}

async function upsertDocument(doc: Document): Promise<void> {
  const embedding = await getEmbedding(doc.content);
  
  await index.upsert([{
    id: doc.id,
    values: embedding,
    metadata: {
      title: doc.title,
      content: doc.content.slice(0, 1000),  // Store snippet
      url: doc.url,
      category: doc.category,
      createdAt: doc.createdAt.toISOString(),
    },
  }]);
}

// Batch upsert (recommended)
async function upsertDocuments(docs: Document[]): Promise<void> {
  const batchSize = 100;
  
  for (let i = 0; i < docs.length; i += batchSize) {
    const batch = docs.slice(i, i + batchSize);
    
    // Get embeddings in parallel
    const embeddings = await getEmbeddings(batch.map(d => d.content));
    
    const vectors = batch.map((doc, idx) => ({
      id: doc.id,
      values: embeddings[idx],
      metadata: {
        title: doc.title,
        content: doc.content.slice(0, 1000),
        url: doc.url,
        category: doc.category,
        createdAt: doc.createdAt.toISOString(),
      },
    }));
    
    await index.upsert(vectors);
    
    console.log(`Upserted ${i + batch.length}/${docs.length}`);
  }
}


// ==========================================
// QUERY VECTORS
// ==========================================

interface SearchResult {
  id: string;
  score: number;
  title: string;
  content: string;
  url?: string;
}

async function searchDocuments(
  query: string,
  topK: number = 10,
  filter?: Record<string, any>
): Promise<SearchResult[]> {
  const queryEmbedding = await getEmbedding(query);
  
  const results = await index.query({
    vector: queryEmbedding,
    topK,
    includeMetadata: true,
    filter,
  });
  
  return results.matches?.map(match => ({
    id: match.id,
    score: match.score ?? 0,
    title: match.metadata?.title as string,
    content: match.metadata?.content as string,
    url: match.metadata?.url as string | undefined,
  })) ?? [];
}

// Search with metadata filter
async function searchByCategory(
  query: string,
  category: string,
  topK: number = 10
): Promise<SearchResult[]> {
  return searchDocuments(query, topK, {
    category: { $eq: category },
  });
}

// Complex filter
async function searchWithFilters(
  query: string,
  options: {
    categories?: string[];
    dateAfter?: Date;
    topK?: number;
  }
): Promise<SearchResult[]> {
  const filter: Record<string, any> = {};
  
  if (options.categories?.length) {
    filter.category = { $in: options.categories };
  }
  
  if (options.dateAfter) {
    filter.createdAt = { $gte: options.dateAfter.toISOString() };
  }
  
  return searchDocuments(query, options.topK ?? 10, filter);
}


// ==========================================
// DELETE VECTORS
// ==========================================

// Delete by ID
await index.deleteOne('doc-123');

// Delete by IDs
await index.deleteMany(['doc-1', 'doc-2', 'doc-3']);

// Delete by filter
await index.deleteMany({
  filter: { category: { $eq: 'outdated' } },
});

// Delete all in namespace
await namespace.deleteAll();
```

---

## 3) Weaviate

### Schema and Client
```typescript
// ==========================================
// WEAVIATE CLIENT
// ==========================================

import weaviate, { WeaviateClient, ApiKey } from 'weaviate-client';

const client: WeaviateClient = await weaviate.connectToWeaviateCloud(
  process.env.WEAVIATE_URL!,
  {
    authCredentials: new ApiKey(process.env.WEAVIATE_API_KEY!),
    headers: {
      'X-OpenAI-Api-Key': process.env.OPENAI_API_KEY!,
    },
  }
);

// Local connection
const localClient = await weaviate.connectToLocal({
  host: 'localhost',
  port: 8080,
  headers: {
    'X-OpenAI-Api-Key': process.env.OPENAI_API_KEY!,
  },
});


// ==========================================
// SCHEMA DEFINITION
// ==========================================

// Create collection with vectorizer
const collection = await client.collections.create({
  name: 'Document',
  description: 'A document in the knowledge base',
  
  // Vectorizer configuration
  vectorizers: [
    weaviate.configure.vectorizer.text2VecOpenAI({
      model: 'text-embedding-3-small',
      sourceProperties: ['title', 'content'],
    }),
  ],
  
  // Properties
  properties: [
    {
      name: 'title',
      dataType: 'text',
      description: 'Document title',
    },
    {
      name: 'content',
      dataType: 'text',
      description: 'Document content',
    },
    {
      name: 'url',
      dataType: 'text',
      description: 'Source URL',
    },
    {
      name: 'category',
      dataType: 'text',
      description: 'Document category',
    },
    {
      name: 'createdAt',
      dataType: 'date',
      description: 'Creation date',
    },
  ],
  
  // Generative module for RAG
  generative: weaviate.configure.generative.openAI({
    model: 'gpt-4o-mini',
  }),
});


// ==========================================
// HYBRID SEARCH SCHEMA
// ==========================================

const hybridCollection = await client.collections.create({
  name: 'Article',
  
  vectorizers: [
    weaviate.configure.vectorizer.text2VecOpenAI({
      model: 'text-embedding-3-small',
      sourceProperties: ['title', 'content'],
    }),
  ],
  
  // Enable BM25 for keyword search
  inverted_index_config: {
    bm25: {
      b: 0.75,
      k1: 1.2,
    },
  },
  
  properties: [
    { name: 'title', dataType: 'text', tokenization: 'word' },
    { name: 'content', dataType: 'text', tokenization: 'word' },
    { name: 'author', dataType: 'text' },
    { name: 'publishedAt', dataType: 'date' },
  ],
});
```

### Insert and Query
```typescript
// ==========================================
// INSERT OBJECTS
// ==========================================

const documents = client.collections.get('Document');

// Single insert (auto-vectorized)
await documents.data.insert({
  title: 'Introduction to Vector Databases',
  content: 'Vector databases are specialized databases...',
  url: 'https://example.com/vector-db',
  category: 'database',
  createdAt: new Date(),
});

// Batch insert
const docsToInsert = [
  { title: 'Doc 1', content: 'Content 1...', category: 'tech' },
  { title: 'Doc 2', content: 'Content 2...', category: 'tech' },
  { title: 'Doc 3', content: 'Content 3...', category: 'science' },
];

await documents.data.insertMany(docsToInsert);

// Insert with custom vector
await documents.data.insert({
  title: 'Pre-vectorized Document',
  content: 'Content here...',
  category: 'custom',
}, {
  vector: [0.1, 0.2, 0.3, ...],  // Pre-computed embedding
});


// ==========================================
// VECTOR SEARCH (Semantic)
// ==========================================

// Near text search
const results = await documents.query.nearText('machine learning basics', {
  limit: 10,
  returnMetadata: ['distance', 'certainty'],
  returnProperties: ['title', 'content', 'url'],
});

for (const item of results.objects) {
  console.log({
    title: item.properties.title,
    distance: item.metadata?.distance,
    certainty: item.metadata?.certainty,
  });
}

// Near vector search
const queryVector = await getEmbedding('machine learning basics');
const vectorResults = await documents.query.nearVector(queryVector, {
  limit: 10,
  returnProperties: ['title', 'content'],
});

// With filter
const filteredResults = await documents.query.nearText('machine learning', {
  limit: 10,
  filters: weaviate.filter
    .byProperty('category').equal('tech')
    .and(weaviate.filter.byProperty('createdAt').greaterThan(new Date('2024-01-01'))),
});


// ==========================================
// HYBRID SEARCH (Keyword + Semantic)
// ==========================================

const articles = client.collections.get('Article');

const hybridResults = await articles.query.hybrid('machine learning neural networks', {
  limit: 10,
  alpha: 0.5,  // 0 = pure BM25, 1 = pure vector
  returnProperties: ['title', 'content', 'author'],
  returnMetadata: ['score'],
});

// Emphasize keyword matching
const keywordFocused = await articles.query.hybrid('exact phrase match', {
  limit: 10,
  alpha: 0.25,  // More weight on BM25
});

// Emphasize semantic matching
const semanticFocused = await articles.query.hybrid('similar meaning search', {
  limit: 10,
  alpha: 0.75,  // More weight on vector
});


// ==========================================
// KEYWORD SEARCH (BM25)
// ==========================================

const bm25Results = await articles.query.bm25('specific keyword', {
  limit: 10,
  queryProperties: ['title', 'content'],
  returnProperties: ['title', 'content'],
});
```

### Generative Search (RAG)
```typescript
// ==========================================
// RETRIEVAL-AUGMENTED GENERATION
// ==========================================

const documents = client.collections.get('Document');

// Single prompt RAG
const ragResult = await documents.generate.nearText(
  'What are the benefits of vector databases?',
  {
    singlePrompt: `
      Based on the following context, answer the question.
      Context: {content}
      Question: What are the benefits of vector databases?
      Answer:
    `,
  },
  {
    limit: 5,
    returnProperties: ['title', 'content'],
  }
);

// Access generated response
for (const item of ragResult.objects) {
  console.log({
    title: item.properties.title,
    generated: item.generated,  // LLM response for this object
  });
}


// Grouped task (combine all results)
const groupedRag = await documents.generate.nearText(
  'vector database use cases',
  {
    groupedTask: `
      You are a helpful assistant. Based on the following documents, 
      provide a comprehensive summary of vector database use cases.
      
      Documents:
      {content}
      
      Summary:
    `,
  },
  {
    limit: 5,
    returnProperties: ['title', 'content'],
  }
);

// Single grouped response
console.log(groupedRag.generatedText);


// ==========================================
// CUSTOM RAG IMPLEMENTATION
// ==========================================

import OpenAI from 'openai';

const openai = new OpenAI();

async function ragQuery(question: string): Promise<string> {
  // 1. Retrieve relevant documents
  const documents = client.collections.get('Document');
  
  const results = await documents.query.nearText(question, {
    limit: 5,
    returnProperties: ['title', 'content'],
  });
  
  // 2. Build context
  const context = results.objects
    .map((obj, i) => `[${i + 1}] ${obj.properties.title}\n${obj.properties.content}`)
    .join('\n\n---\n\n');
  
  // 3. Generate response
  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      {
        role: 'system',
        content: `You are a helpful assistant. Answer questions based on the provided context. 
If the answer is not in the context, say "I don't have enough information to answer that."
Always cite your sources using [1], [2], etc.`,
      },
      {
        role: 'user',
        content: `Context:\n${context}\n\nQuestion: ${question}`,
      },
    ],
    temperature: 0.7,
    max_tokens: 1000,
  });
  
  return response.choices[0].message.content ?? '';
}

// Usage
const answer = await ragQuery('What are the main advantages of using vector databases for AI applications?');
console.log(answer);
```

---

## 4) Complete RAG Pipeline

### Document Processing Pipeline
```typescript
// ==========================================
// FULL RAG PIPELINE
// ==========================================

import { Pinecone } from '@pinecone-database/pinecone';
import OpenAI from 'openai';
import crypto from 'crypto';

const pinecone = new Pinecone({ apiKey: process.env.PINECONE_API_KEY! });
const openai = new OpenAI();
const index = pinecone.index('knowledge-base');

interface DocumentSource {
  id: string;
  title: string;
  content: string;
  url?: string;
  metadata?: Record<string, any>;
}

interface ProcessedChunk {
  id: string;
  text: string;
  embedding: number[];
  metadata: {
    documentId: string;
    title: string;
    chunkIndex: number;
    url?: string;
    [key: string]: any;
  };
}

// Step 1: Process documents into chunks
async function processDocument(doc: DocumentSource): Promise<ProcessedChunk[]> {
  const chunks = chunkMarkdown(doc.content, 1000);
  const texts = chunks.map(c => c.text);
  
  // Get embeddings for all chunks
  const response = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: texts,
  });
  
  return chunks.map((chunk, idx) => ({
    id: `${doc.id}-chunk-${idx}`,
    text: chunk.text,
    embedding: response.data[idx].embedding,
    metadata: {
      documentId: doc.id,
      title: doc.title,
      chunkIndex: idx,
      url: doc.url,
      ...doc.metadata,
    },
  }));
}

// Step 2: Index chunks
async function indexChunks(chunks: ProcessedChunk[]): Promise<void> {
  const vectors = chunks.map(chunk => ({
    id: chunk.id,
    values: chunk.embedding,
    metadata: {
      ...chunk.metadata,
      text: chunk.text,  // Store text for retrieval
    },
  }));
  
  // Batch upsert
  const batchSize = 100;
  for (let i = 0; i < vectors.length; i += batchSize) {
    await index.upsert(vectors.slice(i, i + batchSize));
  }
}

// Step 3: Query with context retrieval
async function retrieveContext(
  query: string,
  topK: number = 5,
  filter?: Record<string, any>
): Promise<{ text: string; metadata: Record<string, any> }[]> {
  const queryEmbedding = await openai.embeddings.create({
    model: 'text-embedding-3-small',
    input: query,
  });
  
  const results = await index.query({
    vector: queryEmbedding.data[0].embedding,
    topK,
    includeMetadata: true,
    filter,
  });
  
  return results.matches?.map(match => ({
    text: match.metadata?.text as string,
    metadata: match.metadata as Record<string, any>,
  })) ?? [];
}

// Step 4: Generate response
async function generateResponse(
  query: string,
  context: { text: string; metadata: Record<string, any> }[]
): Promise<string> {
  const contextText = context
    .map((c, i) => `[Source ${i + 1}: ${c.metadata.title}]\n${c.text}`)
    .join('\n\n---\n\n');
  
  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: `You are a knowledgeable assistant. Answer questions using the provided context.
- Be accurate and helpful
- Cite sources using [Source N] format
- If information is not in the context, acknowledge it
- Be concise but thorough`,
      },
      {
        role: 'user',
        content: `Context:\n${contextText}\n\n---\n\nQuestion: ${query}`,
      },
    ],
    temperature: 0.5,
  });
  
  return response.choices[0].message.content ?? '';
}

// Complete RAG function
async function askQuestion(
  query: string,
  options?: {
    topK?: number;
    filter?: Record<string, any>;
  }
): Promise<{
  answer: string;
  sources: { title: string; url?: string }[];
}> {
  const context = await retrieveContext(
    query,
    options?.topK ?? 5,
    options?.filter
  );
  
  const answer = await generateResponse(query, context);
  
  const sources = [...new Map(
    context.map(c => [c.metadata.documentId, {
      title: c.metadata.title,
      url: c.metadata.url,
    }])
  ).values()];
  
  return { answer, sources };
}

// Usage
const result = await askQuestion('How do vector databases improve search?');
console.log(result.answer);
console.log('Sources:', result.sources);
```

### Streaming RAG
```typescript
// ==========================================
// STREAMING RAG RESPONSE
// ==========================================

async function* streamRAGResponse(query: string): AsyncGenerator<string> {
  const context = await retrieveContext(query, 5);
  
  const contextText = context
    .map((c, i) => `[${i + 1}] ${c.text}`)
    .join('\n\n');
  
  const stream = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: 'Answer based on the provided context. Cite sources using [N].',
      },
      {
        role: 'user',
        content: `Context:\n${contextText}\n\nQuestion: ${query}`,
      },
    ],
    stream: true,
  });
  
  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) {
      yield content;
    }
  }
}

// Usage with streaming
async function handleStreamingQuery(query: string) {
  process.stdout.write('Answer: ');
  
  for await (const chunk of streamRAGResponse(query)) {
    process.stdout.write(chunk);
  }
  
  console.log('\n');
}
```

---

## 5) Distance Metrics

### Choosing the Right Metric
```typescript
// ==========================================
// DISTANCE METRICS
// ==========================================

/*
COSINE SIMILARITY (Most common)
- Range: -1 to 1 (1 = identical direction)
- Best for: Text embeddings, normalized vectors
- Use when: Direction matters more than magnitude
*/

// Pinecone
await pinecone.createIndex({
  name: 'text-search',
  dimension: 1536,
  metric: 'cosine',  // ✅ Best for text
  spec: { serverless: { cloud: 'aws', region: 'us-east-1' } },
});

/*
EUCLIDEAN DISTANCE (L2)
- Range: 0 to ∞ (0 = identical)
- Best for: Image embeddings, clustering
- Use when: Absolute distance matters
*/

await pinecone.createIndex({
  name: 'image-search',
  dimension: 512,
  metric: 'euclidean',  // ✅ For images
  spec: { serverless: { cloud: 'aws', region: 'us-east-1' } },
});

/*
DOT PRODUCT
- Range: -∞ to ∞ (higher = more similar)
- Best for: When vectors are already normalized
- Use when: Maximum inner product search (MIPS)
*/

await pinecone.createIndex({
  name: 'recommendations',
  dimension: 256,
  metric: 'dotproduct',  // For normalized vectors
  spec: { serverless: { cloud: 'aws', region: 'us-east-1' } },
});


// ==========================================
// NORMALIZE VECTORS
// ==========================================

function normalizeVector(vector: number[]): number[] {
  const magnitude = Math.sqrt(
    vector.reduce((sum, val) => sum + val * val, 0)
  );
  
  return vector.map(val => val / magnitude);
}

// Use with dot product for cosine similarity
const normalizedQuery = normalizeVector(queryEmbedding);
```

---

## 6) Best Practices

### Metadata Filtering
```typescript
// ==========================================
// EFFICIENT FILTERING
// ==========================================

// Pinecone filter syntax
const results = await index.query({
  vector: queryEmbedding,
  topK: 10,
  filter: {
    // Equality
    category: { $eq: 'technology' },
    
    // Inequality
    createdAt: { $gte: '2024-01-01' },
    
    // In list
    status: { $in: ['published', 'featured'] },
    
    // Not in list
    author: { $nin: ['anonymous'] },
    
    // AND (implicit)
    $and: [
      { category: { $eq: 'tech' } },
      { rating: { $gte: 4 } },
    ],
    
    // OR
    $or: [
      { category: { $eq: 'tech' } },
      { category: { $eq: 'science' } },
    ],
  },
});


// Weaviate filter syntax
const weaviateResults = await collection.query.nearText(query, {
  filters: weaviate.filter
    .byProperty('category').equal('technology')
    .and(weaviate.filter.byProperty('rating').greaterOrEqual(4))
    .or(weaviate.filter.byProperty('featured').equal(true)),
});
```

### Monitoring and Optimization
```typescript
// ==========================================
// MONITORING
// ==========================================

// Pinecone index stats
const stats = await index.describeIndexStats();
console.log({
  totalVectors: stats.totalRecordCount,
  dimensions: stats.dimension,
  namespaces: stats.namespaces,
});

// Query latency tracking
async function queryWithMetrics(query: string) {
  const start = performance.now();
  
  const results = await searchDocuments(query);
  
  const latency = performance.now() - start;
  console.log(`Query latency: ${latency.toFixed(2)}ms`);
  
  return results;
}

// Batch size optimization
const optimalBatchSize = 100;  // Typically 100-1000 for embeddings
```

---

## Best Practices Checklist

### Embeddings
- [ ] Choose appropriate model
- [ ] Match dimensions to index
- [ ] Normalize if using dot product
- [ ] Batch embedding requests

### Chunking
- [ ] Appropriate chunk size (500-1000)
- [ ] Overlap for context
- [ ] Preserve semantic boundaries
- [ ] Include metadata

### Indexing
- [ ] Choose correct metric
- [ ] Use namespaces for isolation
- [ ] Design metadata schema
- [ ] Batch upserts

### Querying
- [ ] Pre-filter with metadata
- [ ] Tune topK for use case
- [ ] Consider hybrid search
- [ ] Cache common queries

---

**References:**
- [Pinecone Documentation](https://docs.pinecone.io/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [OpenAI Embeddings](https://platform.openai.com/docs/guides/embeddings)
