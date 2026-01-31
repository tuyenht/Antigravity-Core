# Python AI/ML Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **PyTorch:** 2.x | **Transformers:** 4.x
> **Priority:** P0 - Load for all AI/ML Python projects

---

You are an expert in Python, AI, Machine Learning, and Generative AI development.

## Key Principles

- Write clean, efficient, and well-documented code
- Follow PEP 8 and modern Python practices
- Use type hints for better code clarity
- Use modern tooling (uv, ruff)
- Implement proper error handling
- Write modular and reusable code

---

## Project Structure

```
project/
├── src/
│   ├── __init__.py
│   ├── config.py              # Configuration
│   ├── data/
│   │   ├── __init__.py
│   │   ├── dataset.py         # Dataset classes
│   │   └── preprocessing.py   # Data preprocessing
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base.py            # Base model class
│   │   └── transformer.py     # Model architectures
│   ├── training/
│   │   ├── __init__.py
│   │   ├── trainer.py         # Training loop
│   │   └── callbacks.py       # Training callbacks
│   ├── inference/
│   │   ├── __init__.py
│   │   └── predictor.py       # Inference pipeline
│   └── utils/
│       ├── __init__.py
│       └── logging.py
├── notebooks/
│   └── exploration.ipynb
├── tests/
│   ├── conftest.py
│   ├── test_data.py
│   └── test_models.py
├── scripts/
│   ├── train.py
│   └── evaluate.py
├── configs/
│   └── train_config.yaml
├── pyproject.toml
├── .python-version
└── README.md
```

---

## Modern Python Setup

### pyproject.toml
```toml
[project]
name = "my-ml-project"
version = "0.1.0"
description = "ML Project with modern Python"
requires-python = ">=3.11"
dependencies = [
    "torch>=2.2.0",
    "transformers>=4.38.0",
    "datasets>=2.17.0",
    "accelerate>=0.27.0",
    "peft>=0.9.0",
    "bitsandbytes>=0.42.0",
    "wandb>=0.16.0",
    "pydantic>=2.6.0",
    "pydantic-settings>=2.2.0",
    "numpy>=1.26.0",
    "pandas>=2.2.0",
    "scikit-learn>=1.4.0",
    "matplotlib>=3.8.0",
    "seaborn>=0.13.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.2.0",
    "mypy>=1.8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP"]

[tool.mypy]
python_version = "3.11"
strict = true
```

### Using uv (Fast Package Manager)
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment
uv venv

# Install dependencies
uv pip install -r requirements.txt
uv pip install -e ".[dev]"

# Run with uv
uv run python train.py
```

---

## Configuration (Pydantic)

### src/config.py
```python
from pathlib import Path
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class DataConfig(BaseModel):
    train_path: Path
    val_path: Path | None = None
    test_path: Path | None = None
    max_length: int = 512
    batch_size: int = 32
    num_workers: int = 4


class ModelConfig(BaseModel):
    name: str = "bert-base-uncased"
    num_labels: int = 2
    dropout: float = 0.1
    freeze_backbone: bool = False


class TrainingConfig(BaseModel):
    learning_rate: float = 2e-5
    weight_decay: float = 0.01
    epochs: int = 3
    warmup_ratio: float = 0.1
    gradient_accumulation_steps: int = 1
    fp16: bool = True
    gradient_checkpointing: bool = False
    max_grad_norm: float = 1.0


class Config(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="ML_",
        extra="ignore",
    )
    
    project_name: str = "my-project"
    seed: int = 42
    device: str = "cuda"
    output_dir: Path = Path("outputs")
    
    data: DataConfig
    model: ModelConfig
    training: TrainingConfig
    
    # Logging
    wandb_project: str | None = None
    wandb_entity: str | None = None


def load_config(path: Path) -> Config:
    """Load config from YAML file."""
    import yaml
    
    with open(path) as f:
        data = yaml.safe_load(f)
    
    return Config(**data)
```

---

## Data Processing

### src/data/dataset.py
```python
from pathlib import Path
from typing import Any
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import AutoTokenizer
import pandas as pd


class TextClassificationDataset(Dataset):
    """Dataset for text classification."""
    
    def __init__(
        self,
        data_path: Path,
        tokenizer: AutoTokenizer,
        max_length: int = 512,
        text_column: str = "text",
        label_column: str = "label",
    ):
        self.data = pd.read_csv(data_path)
        self.tokenizer = tokenizer
        self.max_length = max_length
        self.text_column = text_column
        self.label_column = label_column
    
    def __len__(self) -> int:
        return len(self.data)
    
    def __getitem__(self, idx: int) -> dict[str, torch.Tensor]:
        row = self.data.iloc[idx]
        text = str(row[self.text_column])
        label = int(row[self.label_column])
        
        encoding = self.tokenizer(
            text,
            max_length=self.max_length,
            padding="max_length",
            truncation=True,
            return_tensors="pt",
        )
        
        return {
            "input_ids": encoding["input_ids"].squeeze(),
            "attention_mask": encoding["attention_mask"].squeeze(),
            "labels": torch.tensor(label, dtype=torch.long),
        }


def create_dataloaders(
    config: "Config",
    tokenizer: AutoTokenizer,
) -> tuple[DataLoader, DataLoader | None]:
    """Create train and validation dataloaders."""
    
    train_dataset = TextClassificationDataset(
        data_path=config.data.train_path,
        tokenizer=tokenizer,
        max_length=config.data.max_length,
    )
    
    train_loader = DataLoader(
        train_dataset,
        batch_size=config.data.batch_size,
        shuffle=True,
        num_workers=config.data.num_workers,
        pin_memory=True,
    )
    
    val_loader = None
    if config.data.val_path:
        val_dataset = TextClassificationDataset(
            data_path=config.data.val_path,
            tokenizer=tokenizer,
            max_length=config.data.max_length,
        )
        val_loader = DataLoader(
            val_dataset,
            batch_size=config.data.batch_size,
            shuffle=False,
            num_workers=config.data.num_workers,
            pin_memory=True,
        )
    
    return train_loader, val_loader
```

---

## PyTorch 2.x Training

### src/training/trainer.py
```python
import torch
from torch import nn
from torch.optim import AdamW
from torch.utils.data import DataLoader
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    get_linear_schedule_with_warmup,
)
from tqdm import tqdm
import wandb


class Trainer:
    """Modern PyTorch trainer with torch.compile."""
    
    def __init__(
        self,
        config: "Config",
        model: nn.Module,
        train_loader: DataLoader,
        val_loader: DataLoader | None = None,
    ):
        self.config = config
        self.device = torch.device(config.device)
        
        # Model
        self.model = model.to(self.device)
        
        # Compile model for faster training (PyTorch 2.0+)
        if hasattr(torch, "compile"):
            self.model = torch.compile(self.model)
        
        # Enable gradient checkpointing for memory efficiency
        if config.training.gradient_checkpointing:
            self.model.gradient_checkpointing_enable()
        
        self.train_loader = train_loader
        self.val_loader = val_loader
        
        # Optimizer
        self.optimizer = AdamW(
            self.model.parameters(),
            lr=config.training.learning_rate,
            weight_decay=config.training.weight_decay,
        )
        
        # Scheduler
        num_training_steps = len(train_loader) * config.training.epochs
        num_warmup_steps = int(num_training_steps * config.training.warmup_ratio)
        
        self.scheduler = get_linear_schedule_with_warmup(
            self.optimizer,
            num_warmup_steps=num_warmup_steps,
            num_training_steps=num_training_steps,
        )
        
        # Mixed precision
        self.scaler = torch.cuda.amp.GradScaler() if config.training.fp16 else None
        
        # Best metrics
        self.best_val_loss = float("inf")
    
    def train(self) -> None:
        """Main training loop."""
        for epoch in range(self.config.training.epochs):
            train_loss = self._train_epoch(epoch)
            
            if self.val_loader:
                val_loss, val_acc = self._validate()
                
                # Log metrics
                metrics = {
                    "epoch": epoch,
                    "train_loss": train_loss,
                    "val_loss": val_loss,
                    "val_accuracy": val_acc,
                }
                
                if self.config.wandb_project:
                    wandb.log(metrics)
                
                print(f"Epoch {epoch}: train_loss={train_loss:.4f}, "
                      f"val_loss={val_loss:.4f}, val_acc={val_acc:.4f}")
                
                # Save best model
                if val_loss < self.best_val_loss:
                    self.best_val_loss = val_loss
                    self._save_checkpoint("best")
            else:
                print(f"Epoch {epoch}: train_loss={train_loss:.4f}")
        
        # Save final model
        self._save_checkpoint("final")
    
    def _train_epoch(self, epoch: int) -> float:
        """Train for one epoch."""
        self.model.train()
        total_loss = 0.0
        
        progress = tqdm(self.train_loader, desc=f"Epoch {epoch}")
        
        for step, batch in enumerate(progress):
            # Move to device
            batch = {k: v.to(self.device) for k, v in batch.items()}
            
            # Forward pass with mixed precision
            with torch.cuda.amp.autocast(enabled=self.scaler is not None):
                outputs = self.model(**batch)
                loss = outputs.loss
                loss = loss / self.config.training.gradient_accumulation_steps
            
            # Backward pass
            if self.scaler:
                self.scaler.scale(loss).backward()
            else:
                loss.backward()
            
            # Gradient accumulation
            if (step + 1) % self.config.training.gradient_accumulation_steps == 0:
                if self.scaler:
                    self.scaler.unscale_(self.optimizer)
                    torch.nn.utils.clip_grad_norm_(
                        self.model.parameters(),
                        self.config.training.max_grad_norm
                    )
                    self.scaler.step(self.optimizer)
                    self.scaler.update()
                else:
                    torch.nn.utils.clip_grad_norm_(
                        self.model.parameters(),
                        self.config.training.max_grad_norm
                    )
                    self.optimizer.step()
                
                self.scheduler.step()
                self.optimizer.zero_grad()
            
            total_loss += loss.item()
            progress.set_postfix({"loss": loss.item()})
        
        return total_loss / len(self.train_loader)
    
    @torch.no_grad()
    def _validate(self) -> tuple[float, float]:
        """Validate the model."""
        self.model.eval()
        total_loss = 0.0
        correct = 0
        total = 0
        
        for batch in self.val_loader:
            batch = {k: v.to(self.device) for k, v in batch.items()}
            
            outputs = self.model(**batch)
            total_loss += outputs.loss.item()
            
            predictions = outputs.logits.argmax(dim=-1)
            correct += (predictions == batch["labels"]).sum().item()
            total += batch["labels"].size(0)
        
        avg_loss = total_loss / len(self.val_loader)
        accuracy = correct / total
        
        return avg_loss, accuracy
    
    def _save_checkpoint(self, name: str) -> None:
        """Save model checkpoint."""
        output_dir = self.config.output_dir / name
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Save model
        self.model.save_pretrained(output_dir)
        
        # Save training state
        torch.save({
            "optimizer": self.optimizer.state_dict(),
            "scheduler": self.scheduler.state_dict(),
            "scaler": self.scaler.state_dict() if self.scaler else None,
        }, output_dir / "training_state.pt")
```

---

## LLM Fine-tuning (LoRA)

### src/training/lora_trainer.py
```python
import torch
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    TrainingArguments,
)
from peft import (
    LoraConfig,
    get_peft_model,
    prepare_model_for_kbit_training,
    TaskType,
)
from trl import SFTTrainer
from datasets import load_dataset


def train_lora(
    model_name: str = "meta-llama/Llama-2-7b-hf",
    dataset_name: str = "tatsu-lab/alpaca",
    output_dir: str = "outputs/lora",
    epochs: int = 3,
    batch_size: int = 4,
    learning_rate: float = 2e-4,
    lora_r: int = 16,
    lora_alpha: int = 32,
    use_4bit: bool = True,
):
    """Fine-tune LLM with LoRA/QLoRA."""
    
    # Quantization config for QLoRA
    bnb_config = BitsAndBytesConfig(
        load_in_4bit=use_4bit,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.bfloat16,
        bnb_4bit_use_double_quant=True,
    ) if use_4bit else None
    
    # Load model
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        quantization_config=bnb_config,
        device_map="auto",
        trust_remote_code=True,
        torch_dtype=torch.bfloat16,
    )
    
    # Prepare for k-bit training
    if use_4bit:
        model = prepare_model_for_kbit_training(model)
    
    # LoRA config
    lora_config = LoraConfig(
        task_type=TaskType.CAUSAL_LM,
        r=lora_r,
        lora_alpha=lora_alpha,
        lora_dropout=0.05,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
        bias="none",
    )
    
    # Apply LoRA
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()
    
    # Tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    tokenizer.pad_token = tokenizer.eos_token
    tokenizer.padding_side = "right"
    
    # Load dataset
    dataset = load_dataset(dataset_name)
    
    # Format function
    def format_instruction(sample: dict) -> str:
        return f"""### Instruction:
{sample['instruction']}

### Input:
{sample.get('input', '')}

### Response:
{sample['output']}"""
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir=output_dir,
        num_train_epochs=epochs,
        per_device_train_batch_size=batch_size,
        gradient_accumulation_steps=4,
        learning_rate=learning_rate,
        weight_decay=0.001,
        warmup_ratio=0.03,
        lr_scheduler_type="cosine",
        logging_steps=10,
        save_strategy="epoch",
        fp16=True,
        optim="paged_adamw_8bit",
        gradient_checkpointing=True,
        report_to="wandb",
    )
    
    # Trainer
    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=dataset["train"],
        formatting_func=format_instruction,
        args=training_args,
        max_seq_length=512,
        packing=True,
    )
    
    # Train
    trainer.train()
    
    # Save
    trainer.save_model(output_dir)
    
    return model, tokenizer
```

---

## RAG (Retrieval-Augmented Generation)

### src/rag/retriever.py
```python
from typing import Any
import numpy as np
from sentence_transformers import SentenceTransformer
import chromadb
from chromadb.config import Settings


class VectorStore:
    """Vector store for RAG with ChromaDB."""
    
    def __init__(
        self,
        collection_name: str = "documents",
        embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2",
        persist_directory: str | None = None,
    ):
        # Embedding model
        self.encoder = SentenceTransformer(embedding_model)
        
        # ChromaDB client
        if persist_directory:
            self.client = chromadb.PersistentClient(path=persist_directory)
        else:
            self.client = chromadb.Client()
        
        # Get or create collection
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"}
        )
    
    def add_documents(
        self,
        documents: list[str],
        metadatas: list[dict[str, Any]] | None = None,
        ids: list[str] | None = None,
    ) -> None:
        """Add documents to the vector store."""
        # Generate IDs if not provided
        if ids is None:
            ids = [f"doc_{i}" for i in range(len(documents))]
        
        # Generate embeddings
        embeddings = self.encoder.encode(documents).tolist()
        
        # Add to collection
        self.collection.add(
            documents=documents,
            embeddings=embeddings,
            metadatas=metadatas or [{}] * len(documents),
            ids=ids,
        )
    
    def search(
        self,
        query: str,
        n_results: int = 5,
    ) -> list[dict[str, Any]]:
        """Search for similar documents."""
        # Generate query embedding
        query_embedding = self.encoder.encode([query]).tolist()
        
        # Search
        results = self.collection.query(
            query_embeddings=query_embedding,
            n_results=n_results,
            include=["documents", "metadatas", "distances"],
        )
        
        # Format results
        documents = []
        for i in range(len(results["ids"][0])):
            documents.append({
                "id": results["ids"][0][i],
                "document": results["documents"][0][i],
                "metadata": results["metadatas"][0][i],
                "distance": results["distances"][0][i],
            })
        
        return documents


class RAGPipeline:
    """RAG pipeline for question answering."""
    
    def __init__(
        self,
        vector_store: VectorStore,
        llm_model: str = "meta-llama/Llama-2-7b-chat-hf",
    ):
        self.vector_store = vector_store
        
        # Load LLM
        from transformers import AutoModelForCausalLM, AutoTokenizer
        import torch
        
        self.tokenizer = AutoTokenizer.from_pretrained(llm_model)
        self.model = AutoModelForCausalLM.from_pretrained(
            llm_model,
            torch_dtype=torch.float16,
            device_map="auto",
        )
    
    def generate(
        self,
        query: str,
        n_context: int = 3,
        max_new_tokens: int = 512,
    ) -> str:
        """Generate answer using RAG."""
        # Retrieve relevant documents
        docs = self.vector_store.search(query, n_results=n_context)
        
        # Build context
        context = "\n\n".join([doc["document"] for doc in docs])
        
        # Build prompt
        prompt = f"""Use the following context to answer the question.

Context:
{context}

Question: {query}

Answer:"""
        
        # Generate
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=0.7,
            top_p=0.9,
            pad_token_id=self.tokenizer.eos_token_id,
        )
        
        response = self.tokenizer.decode(
            outputs[0][inputs["input_ids"].shape[1]:],
            skip_special_tokens=True
        )
        
        return response
```

---

## LangChain Integration

### src/langchain/agent.py
```python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain.tools import tool
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings


# Define tools
@tool
def search_documents(query: str) -> str:
    """Search documents in the knowledge base."""
    embeddings = OpenAIEmbeddings()
    vectorstore = Chroma(
        persist_directory="./chroma_db",
        embedding_function=embeddings
    )
    
    docs = vectorstore.similarity_search(query, k=3)
    return "\n\n".join([doc.page_content for doc in docs])


@tool
def calculate(expression: str) -> str:
    """Calculate mathematical expression."""
    try:
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"Error: {e}"


def create_agent():
    """Create LangChain agent with tools."""
    # LLM
    llm = ChatOpenAI(model="gpt-4-turbo-preview", temperature=0)
    
    # Tools
    tools = [search_documents, calculate]
    
    # Prompt
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful AI assistant with access to tools."),
        ("human", "{input}"),
        ("placeholder", "{agent_scratchpad}"),
    ])
    
    # Create agent
    agent = create_tool_calling_agent(llm, tools, prompt)
    
    # Executor
    executor = AgentExecutor(
        agent=agent,
        tools=tools,
        verbose=True,
        max_iterations=5,
    )
    
    return executor


# Simple chain example
def create_chain():
    """Create simple LangChain chain."""
    llm = ChatOpenAI(model="gpt-4-turbo-preview")
    
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a helpful assistant that answers questions concisely."),
        ("human", "{question}"),
    ])
    
    chain = prompt | llm | StrOutputParser()
    
    return chain


# Usage
if __name__ == "__main__":
    # Simple chain
    chain = create_chain()
    response = chain.invoke({"question": "What is Python?"})
    print(response)
    
    # Agent with tools
    agent = create_agent()
    result = agent.invoke({"input": "Search for information about machine learning"})
    print(result["output"])
```

---

## Inference

### src/inference/predictor.py
```python
from pathlib import Path
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer


class Predictor:
    """Inference predictor for classification."""
    
    def __init__(
        self,
        model_path: Path | str,
        device: str = "cuda" if torch.cuda.is_available() else "cpu",
    ):
        self.device = torch.device(device)
        
        # Load model and tokenizer
        self.model = AutoModelForSequenceClassification.from_pretrained(
            model_path
        ).to(self.device)
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        
        # Set to eval mode
        self.model.eval()
        
        # Compile for faster inference
        if hasattr(torch, "compile"):
            self.model = torch.compile(self.model)
    
    @torch.no_grad()
    def predict(
        self,
        texts: str | list[str],
        batch_size: int = 32,
    ) -> list[dict]:
        """Predict labels for texts."""
        if isinstance(texts, str):
            texts = [texts]
        
        results = []
        
        for i in range(0, len(texts), batch_size):
            batch_texts = texts[i:i + batch_size]
            
            # Tokenize
            inputs = self.tokenizer(
                batch_texts,
                padding=True,
                truncation=True,
                max_length=512,
                return_tensors="pt",
            ).to(self.device)
            
            # Forward
            outputs = self.model(**inputs)
            
            # Get probabilities
            probs = torch.softmax(outputs.logits, dim=-1)
            predictions = probs.argmax(dim=-1)
            
            for j, (pred, prob) in enumerate(zip(predictions, probs)):
                results.append({
                    "text": batch_texts[j],
                    "label": pred.item(),
                    "confidence": prob[pred].item(),
                    "probabilities": prob.tolist(),
                })
        
        return results


# LLM Inference
class LLMPredictor:
    """Inference for causal LLMs."""
    
    def __init__(
        self,
        model_name: str = "meta-llama/Llama-2-7b-chat-hf",
        device: str = "cuda",
    ):
        from transformers import AutoModelForCausalLM
        
        self.device = torch.device(device)
        
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForCausalLM.from_pretrained(
            model_name,
            torch_dtype=torch.float16,
            device_map="auto",
        )
    
    @torch.no_grad()
    def generate(
        self,
        prompt: str,
        max_new_tokens: int = 256,
        temperature: float = 0.7,
        top_p: float = 0.9,
        **kwargs,
    ) -> str:
        """Generate text from prompt."""
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            temperature=temperature,
            top_p=top_p,
            do_sample=True,
            pad_token_id=self.tokenizer.eos_token_id,
            **kwargs,
        )
        
        response = self.tokenizer.decode(
            outputs[0][inputs["input_ids"].shape[1]:],
            skip_special_tokens=True
        )
        
        return response
```

---

## Testing

### tests/test_models.py
```python
import pytest
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer


@pytest.fixture
def model_and_tokenizer():
    """Load model and tokenizer for testing."""
    model_name = "distilbert-base-uncased"
    model = AutoModelForSequenceClassification.from_pretrained(
        model_name,
        num_labels=2
    )
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    return model, tokenizer


def test_model_forward(model_and_tokenizer):
    """Test model forward pass."""
    model, tokenizer = model_and_tokenizer
    
    inputs = tokenizer(
        "This is a test sentence.",
        return_tensors="pt"
    )
    
    with torch.no_grad():
        outputs = model(**inputs)
    
    assert outputs.logits.shape == (1, 2)
    assert not torch.isnan(outputs.logits).any()


def test_model_batch(model_and_tokenizer):
    """Test model with batch input."""
    model, tokenizer = model_and_tokenizer
    
    texts = ["First sentence", "Second sentence", "Third sentence"]
    inputs = tokenizer(
        texts,
        padding=True,
        return_tensors="pt"
    )
    
    with torch.no_grad():
        outputs = model(**inputs)
    
    assert outputs.logits.shape == (3, 2)


def test_model_gradient(model_and_tokenizer):
    """Test model gradient computation."""
    model, tokenizer = model_and_tokenizer
    
    inputs = tokenizer("Test", return_tensors="pt")
    labels = torch.tensor([1])
    
    outputs = model(**inputs, labels=labels)
    loss = outputs.loss
    
    loss.backward()
    
    # Check gradients exist
    for param in model.parameters():
        if param.requires_grad:
            assert param.grad is not None
```

---

## Best Practices Checklist

- [ ] Use Python 3.11+ with type hints
- [ ] Use uv for package management
- [ ] Use ruff for linting and formatting
- [ ] Use Pydantic for configuration and validation
- [ ] Use PyTorch 2.x with torch.compile()
- [ ] Implement gradient checkpointing for large models
- [ ] Use mixed precision training (fp16/bf16)
- [ ] Track experiments with W&B or MLflow
- [ ] Use LoRA/QLoRA for efficient fine-tuning
- [ ] Implement proper testing with pytest

---

**References:**
- [PyTorch 2.0](https://pytorch.org/)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [PEFT Library](https://huggingface.co/docs/peft)
- [LangChain](https://python.langchain.com/)
- [ChromaDB](https://docs.trychroma.com/)
