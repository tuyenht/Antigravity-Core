# Python Async Programming Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Features:** TaskGroup, timeout, ExceptionGroup
> **Priority:** P1 - Load for async Python projects

---

You are an expert in Python asynchronous programming with asyncio.

## Key Principles

- Use async/await for I/O-bound operations
- Use structured concurrency (TaskGroup)
- Understand event loop mechanics
- Avoid blocking the event loop
- Handle cancellation and timeouts properly
- Use Python 3.11+ async features

---

## Async Fundamentals

### Basic Coroutines
```python
import asyncio
from typing import Coroutine, Awaitable


async def fetch_data(url: str) -> dict:
    """Async function (coroutine)."""
    await asyncio.sleep(1)  # Never use time.sleep()!
    return {"url": url, "data": "..."}


async def main():
    # Await a single coroutine
    result = await fetch_data("https://api.example.com")
    print(result)


# Entry point
if __name__ == "__main__":
    asyncio.run(main())
```

### Running Multiple Coroutines
```python
async def main():
    # Sequential - slow!
    result1 = await fetch_data("url1")
    result2 = await fetch_data("url2")
    
    # Concurrent - fast!
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        fetch_data("url3"),
    )
    
    # With exception handling
    results = await asyncio.gather(
        fetch_data("url1"),
        fetch_data("url2"),
        return_exceptions=True,  # Don't raise, return exceptions
    )
    
    for result in results:
        if isinstance(result, Exception):
            print(f"Error: {result}")
        else:
            print(f"Success: {result}")
```

---

## TaskGroup (Python 3.11+)

### Structured Concurrency
```python
import asyncio


async def process_item(item: str) -> str:
    """Process single item."""
    await asyncio.sleep(0.1)
    if item == "error":
        raise ValueError(f"Failed to process: {item}")
    return f"Processed: {item}"


async def main():
    items = ["a", "b", "c", "d"]
    results = []
    
    # TaskGroup ensures all tasks complete or cancel together
    async with asyncio.TaskGroup() as tg:
        tasks = [
            tg.create_task(process_item(item))
            for item in items
        ]
    
    # All tasks completed successfully
    results = [task.result() for task in tasks]
    print(results)


# Handling exceptions with ExceptionGroup
async def main_with_errors():
    items = ["a", "error", "c"]
    
    try:
        async with asyncio.TaskGroup() as tg:
            tasks = [
                tg.create_task(process_item(item))
                for item in items
            ]
    except* ValueError as eg:
        # Handle all ValueError exceptions
        for exc in eg.exceptions:
            print(f"ValueError: {exc}")
    except* Exception as eg:
        # Handle all other exceptions
        for exc in eg.exceptions:
            print(f"Other error: {exc}")


if __name__ == "__main__":
    asyncio.run(main())
```

### TaskGroup vs gather()
```python
# gather() - exceptions can leave tasks orphaned
async def with_gather():
    try:
        results = await asyncio.gather(
            task1(),
            task2(),  # If this fails...
            task3(),  # ...this might still be running!
        )
    except Exception:
        # Some tasks may not be cleaned up properly
        pass


# TaskGroup - proper cleanup guaranteed
async def with_taskgroup():
    try:
        async with asyncio.TaskGroup() as tg:
            t1 = tg.create_task(task1())
            t2 = tg.create_task(task2())  # If this fails...
            t3 = tg.create_task(task3())  # ...t1 and t3 are cancelled!
    except* Exception:
        # All tasks properly cleaned up
        pass
```

---

## Timeouts (Python 3.11+)

### asyncio.timeout
```python
import asyncio


async def slow_operation():
    await asyncio.sleep(10)
    return "done"


async def main():
    # New Python 3.11+ timeout context manager
    try:
        async with asyncio.timeout(2.0):
            result = await slow_operation()
    except TimeoutError:
        print("Operation timed out!")
    
    # With deadline
    deadline = asyncio.get_running_loop().time() + 5.0
    async with asyncio.timeout_at(deadline):
        await slow_operation()
    
    # Reschedule timeout
    async with asyncio.timeout(10.0) as cm:
        await some_operation()
        # Extend timeout by 5 more seconds
        cm.reschedule(asyncio.get_running_loop().time() + 5.0)
        await another_operation()


# Legacy wait_for (still works)
async def main_legacy():
    try:
        result = await asyncio.wait_for(slow_operation(), timeout=2.0)
    except asyncio.TimeoutError:
        print("Timed out!")
```

---

## Concurrency Patterns

### Semaphore for Rate Limiting
```python
import asyncio
import httpx


class RateLimitedClient:
    """HTTP client with rate limiting."""
    
    def __init__(self, max_concurrent: int = 10):
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.client = httpx.AsyncClient()
    
    async def fetch(self, url: str) -> dict:
        async with self.semaphore:
            response = await self.client.get(url)
            return response.json()
    
    async def fetch_many(self, urls: list[str]) -> list[dict]:
        async with asyncio.TaskGroup() as tg:
            tasks = [tg.create_task(self.fetch(url)) for url in urls]
        return [task.result() for task in tasks]
    
    async def close(self):
        await self.client.aclose()
    
    async def __aenter__(self):
        return self
    
    async def __aexit__(self, *args):
        await self.close()


# Usage
async def main():
    urls = [f"https://api.example.com/items/{i}" for i in range(100)]
    
    async with RateLimitedClient(max_concurrent=5) as client:
        results = await client.fetch_many(urls)
        print(f"Fetched {len(results)} items")
```

### Producer-Consumer Pattern
```python
import asyncio
from dataclasses import dataclass
from typing import Any


@dataclass
class Task:
    id: int
    data: Any


class AsyncWorkerPool:
    """Async worker pool with queue."""
    
    def __init__(self, num_workers: int = 5, queue_size: int = 100):
        self.num_workers = num_workers
        self.queue: asyncio.Queue[Task | None] = asyncio.Queue(maxsize=queue_size)
        self.results: list[Any] = []
        self._workers: list[asyncio.Task] = []
    
    async def worker(self, worker_id: int):
        """Worker coroutine."""
        while True:
            task = await self.queue.get()
            
            if task is None:  # Poison pill
                self.queue.task_done()
                break
            
            try:
                result = await self.process(task)
                self.results.append(result)
            except Exception as e:
                print(f"Worker {worker_id} error: {e}")
            finally:
                self.queue.task_done()
    
    async def process(self, task: Task) -> Any:
        """Process a single task. Override in subclass."""
        await asyncio.sleep(0.1)  # Simulate work
        return f"Processed {task.id}"
    
    async def submit(self, task: Task):
        """Submit task to queue."""
        await self.queue.put(task)
    
    async def start(self):
        """Start workers."""
        self._workers = [
            asyncio.create_task(self.worker(i))
            for i in range(self.num_workers)
        ]
    
    async def stop(self):
        """Stop workers gracefully."""
        # Send poison pills
        for _ in range(self.num_workers):
            await self.queue.put(None)
        
        # Wait for workers to finish
        await asyncio.gather(*self._workers)
    
    async def __aenter__(self):
        await self.start()
        return self
    
    async def __aexit__(self, *args):
        await self.stop()


# Usage
async def main():
    async with AsyncWorkerPool(num_workers=3) as pool:
        # Submit tasks
        for i in range(20):
            await pool.submit(Task(id=i, data=f"data_{i}"))
        
        # Wait for all tasks to complete
        await pool.queue.join()
    
    print(f"Results: {pool.results}")


asyncio.run(main())
```

### as_completed for Progressive Results
```python
import asyncio
import random


async def fetch_with_delay(url: str) -> dict:
    delay = random.uniform(0.1, 2.0)
    await asyncio.sleep(delay)
    return {"url": url, "delay": delay}


async def main():
    urls = [f"https://example.com/{i}" for i in range(10)]
    
    # Create tasks
    tasks = [asyncio.create_task(fetch_with_delay(url)) for url in urls]
    
    # Process results as they complete
    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"Got result: {result['url']} in {result['delay']:.2f}s")


asyncio.run(main())
```

---

## Synchronization Primitives

### Lock for Mutual Exclusion
```python
import asyncio


class AsyncCounter:
    """Thread-safe async counter."""
    
    def __init__(self):
        self._value = 0
        self._lock = asyncio.Lock()
    
    async def increment(self):
        async with self._lock:
            current = self._value
            await asyncio.sleep(0.01)  # Simulate some work
            self._value = current + 1
    
    @property
    def value(self):
        return self._value


async def main():
    counter = AsyncCounter()
    
    # Without lock, this would have race conditions
    async with asyncio.TaskGroup() as tg:
        for _ in range(100):
            tg.create_task(counter.increment())
    
    print(f"Counter value: {counter.value}")  # Should be 100


asyncio.run(main())
```

### Event for Signaling
```python
import asyncio


async def waiter(event: asyncio.Event, name: str):
    print(f"{name} waiting for event...")
    await event.wait()
    print(f"{name} got the event!")


async def setter(event: asyncio.Event):
    await asyncio.sleep(2)
    print("Setting event!")
    event.set()


async def main():
    event = asyncio.Event()
    
    async with asyncio.TaskGroup() as tg:
        tg.create_task(waiter(event, "Waiter 1"))
        tg.create_task(waiter(event, "Waiter 2"))
        tg.create_task(setter(event))


asyncio.run(main())
```

### Condition for Complex Coordination
```python
import asyncio
from collections import deque


class AsyncQueue:
    """Bounded async queue with Condition."""
    
    def __init__(self, maxsize: int = 10):
        self._queue: deque = deque()
        self._maxsize = maxsize
        self._condition = asyncio.Condition()
    
    async def put(self, item):
        async with self._condition:
            while len(self._queue) >= self._maxsize:
                await self._condition.wait()
            self._queue.append(item)
            self._condition.notify()
    
    async def get(self):
        async with self._condition:
            while not self._queue:
                await self._condition.wait()
            item = self._queue.popleft()
            self._condition.notify()
            return item


async def producer(queue: AsyncQueue, n: int):
    for i in range(n):
        await queue.put(i)
        print(f"Produced: {i}")
        await asyncio.sleep(0.1)


async def consumer(queue: AsyncQueue, n: int):
    for _ in range(n):
        item = await queue.get()
        print(f"Consumed: {item}")
        await asyncio.sleep(0.2)


async def main():
    queue = AsyncQueue(maxsize=5)
    
    async with asyncio.TaskGroup() as tg:
        tg.create_task(producer(queue, 10))
        tg.create_task(consumer(queue, 10))


asyncio.run(main())
```

---

## Error Handling

### Proper Exception Handling
```python
import asyncio


async def risky_operation():
    await asyncio.sleep(1)
    raise ValueError("Something went wrong!")


async def main():
    # Basic try/except
    try:
        await risky_operation()
    except ValueError as e:
        print(f"Caught error: {e}")
    
    # Handling CancelledError
    async def cancellable_task():
        try:
            await asyncio.sleep(10)
        except asyncio.CancelledError:
            print("Task was cancelled!")
            # Cleanup code here
            raise  # Always re-raise CancelledError
    
    task = asyncio.create_task(cancellable_task())
    await asyncio.sleep(0.5)
    task.cancel()
    
    try:
        await task
    except asyncio.CancelledError:
        print("Task cancellation confirmed")


# Shield to protect critical operations
async def critical_save(data: dict):
    """Save data - should not be interrupted."""
    await asyncio.sleep(1)
    print(f"Saved: {data}")


async def main_with_shield():
    task = asyncio.create_task(
        asyncio.shield(critical_save({"important": "data"}))
    )
    
    await asyncio.sleep(0.1)
    task.cancel()  # Won't actually cancel the shielded operation
    
    try:
        await task
    except asyncio.CancelledError:
        print("Outer task cancelled, but save continues...")
        await asyncio.sleep(2)  # Wait for save to complete
```

### ExceptionGroup Handling (Python 3.11+)
```python
import asyncio


async def might_fail(n: int):
    if n % 3 == 0:
        raise ValueError(f"Bad value: {n}")
    if n % 5 == 0:
        raise TypeError(f"Wrong type: {n}")
    return n * 2


async def main():
    try:
        async with asyncio.TaskGroup() as tg:
            tasks = [tg.create_task(might_fail(i)) for i in range(1, 16)]
    except* ValueError as eg:
        print(f"ValueErrors: {len(eg.exceptions)}")
        for exc in eg.exceptions:
            print(f"  - {exc}")
    except* TypeError as eg:
        print(f"TypeErrors: {len(eg.exceptions)}")
        for exc in eg.exceptions:
            print(f"  - {exc}")
    except* Exception as eg:
        print(f"Other errors: {len(eg.exceptions)}")


asyncio.run(main())
```

---

## Async Context Managers

### Creating Async Context Managers
```python
import asyncio
from contextlib import asynccontextmanager


# Class-based
class AsyncDatabaseConnection:
    def __init__(self, url: str):
        self.url = url
        self.connection = None
    
    async def __aenter__(self):
        print(f"Connecting to {self.url}...")
        await asyncio.sleep(0.1)  # Simulate connection
        self.connection = {"url": self.url}
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        print("Closing connection...")
        await asyncio.sleep(0.1)  # Simulate cleanup
        self.connection = None
        return False  # Don't suppress exceptions
    
    async def query(self, sql: str) -> list:
        await asyncio.sleep(0.1)
        return [{"result": "data"}]


# Decorator-based
@asynccontextmanager
async def async_db_connection(url: str):
    print(f"Connecting to {url}...")
    connection = await create_connection(url)
    try:
        yield connection
    finally:
        print("Closing connection...")
        await connection.close()


# Usage
async def main():
    async with AsyncDatabaseConnection("postgresql://localhost/db") as db:
        results = await db.query("SELECT * FROM users")
        print(results)


asyncio.run(main())
```

---

## Graceful Shutdown

### Proper Shutdown Handling
```python
import asyncio
import signal
from typing import Set


class AsyncServer:
    """Server with graceful shutdown."""
    
    def __init__(self):
        self.running = True
        self.tasks: Set[asyncio.Task] = set()
        self._shutdown_event = asyncio.Event()
    
    def _signal_handler(self, sig):
        print(f"\nReceived {sig.name}, initiating shutdown...")
        self.running = False
        self._shutdown_event.set()
    
    async def handle_request(self, request_id: int):
        """Handle a single request."""
        try:
            await asyncio.sleep(1)  # Processing
            print(f"Completed request {request_id}")
        except asyncio.CancelledError:
            print(f"Request {request_id} cancelled")
            raise
    
    async def accept_requests(self):
        """Accept and process requests."""
        request_id = 0
        while self.running:
            # Simulate accepting requests
            await asyncio.sleep(0.1)
            request_id += 1
            
            task = asyncio.create_task(self.handle_request(request_id))
            self.tasks.add(task)
            task.add_done_callback(self.tasks.discard)
    
    async def shutdown(self):
        """Graceful shutdown."""
        print("Shutting down...")
        
        # Cancel all pending tasks
        for task in self.tasks:
            task.cancel()
        
        # Wait for tasks to complete
        if self.tasks:
            await asyncio.gather(*self.tasks, return_exceptions=True)
        
        print("Shutdown complete")
    
    async def run(self):
        """Run the server."""
        loop = asyncio.get_running_loop()
        
        # Setup signal handlers
        for sig in (signal.SIGINT, signal.SIGTERM):
            loop.add_signal_handler(
                sig,
                lambda s=sig: self._signal_handler(s)
            )
        
        try:
            # Run until shutdown requested
            accept_task = asyncio.create_task(self.accept_requests())
            await self._shutdown_event.wait()
            accept_task.cancel()
            
            try:
                await accept_task
            except asyncio.CancelledError:
                pass
            
        finally:
            await self.shutdown()


async def main():
    server = AsyncServer()
    await server.run()


if __name__ == "__main__":
    asyncio.run(main())
```

---

## anyio (Backend Agnostic)

### Using anyio for Portability
```python
import anyio


async def fetch_data(url: str) -> bytes:
    """Works with asyncio AND trio."""
    async with anyio.create_task_group() as tg:
        # Limit concurrency
        limiter = anyio.CapacityLimiter(10)
        
        async with limiter:
            # HTTP request would go here
            await anyio.sleep(1)
            return b"data"


async def main():
    # TaskGroup (similar to asyncio.TaskGroup)
    async with anyio.create_task_group() as tg:
        tg.start_soon(fetch_data, "url1")
        tg.start_soon(fetch_data, "url2")
    
    # Cancellation scope with timeout
    with anyio.move_on_after(5.0):
        await slow_operation()
    
    # Fail on timeout
    with anyio.fail_after(5.0):
        await slow_operation()


# Run with asyncio backend (default)
anyio.run(main)

# Or with trio backend
# anyio.run(main, backend="trio")
```

---

## Testing Async Code

### pytest-asyncio
```python
import pytest
import asyncio


# Fixtures
@pytest.fixture
async def async_client():
    client = AsyncClient()
    await client.connect()
    yield client
    await client.disconnect()


# Tests
@pytest.mark.asyncio
async def test_fetch_data():
    result = await fetch_data("https://api.example.com")
    assert "data" in result


@pytest.mark.asyncio
async def test_timeout_handling():
    with pytest.raises(asyncio.TimeoutError):
        async with asyncio.timeout(0.1):
            await asyncio.sleep(1)


@pytest.mark.asyncio
async def test_concurrent_operations(async_client):
    results = await asyncio.gather(
        async_client.get("/endpoint1"),
        async_client.get("/endpoint2"),
    )
    assert len(results) == 2


@pytest.mark.asyncio
async def test_exception_group():
    with pytest.raises(ExceptionGroup) as exc_info:
        async with asyncio.TaskGroup() as tg:
            tg.create_task(failing_task())
            tg.create_task(another_failing_task())
    
    assert len(exc_info.value.exceptions) == 2


# Testing cancellation
@pytest.mark.asyncio
async def test_cancellation():
    task = asyncio.create_task(long_running_task())
    await asyncio.sleep(0.1)
    task.cancel()
    
    with pytest.raises(asyncio.CancelledError):
        await task
```

---

## Performance Monitoring

### Event Loop Monitoring
```python
import asyncio
import time
from typing import Callable


class EventLoopMonitor:
    """Monitor event loop lag and slow callbacks."""
    
    def __init__(self, threshold_ms: float = 100):
        self.threshold = threshold_ms / 1000
        self._original_run = None
    
    def start(self, loop: asyncio.AbstractEventLoop):
        """Start monitoring."""
        self._original_run = loop._run_once
        
        def monitored_run():
            start = time.perf_counter()
            self._original_run()
            elapsed = time.perf_counter() - start
            
            if elapsed > self.threshold:
                print(f"⚠️ Slow callback: {elapsed*1000:.1f}ms")
        
        loop._run_once = monitored_run
    
    def stop(self, loop: asyncio.AbstractEventLoop):
        """Stop monitoring."""
        if self._original_run:
            loop._run_once = self._original_run


# Simple lag check
async def check_event_loop_lag():
    """Periodically check event loop responsiveness."""
    while True:
        start = time.perf_counter()
        await asyncio.sleep(0.1)
        elapsed = time.perf_counter() - start
        lag = (elapsed - 0.1) * 1000
        
        if lag > 10:
            print(f"Event loop lag: {lag:.1f}ms")
        
        await asyncio.sleep(1)
```

---

## Best Practices Checklist

- [ ] Use TaskGroup for structured concurrency
- [ ] Use asyncio.timeout() for timeouts (Python 3.11+)
- [ ] Handle ExceptionGroup properly
- [ ] Use Semaphore for rate limiting
- [ ] Implement graceful shutdown
- [ ] Never block the event loop
- [ ] Use async context managers for resources
- [ ] Test with pytest-asyncio
- [ ] Monitor event loop lag in production
- [ ] Use anyio for backend portability

---

**References:**
- [Python asyncio Docs](https://docs.python.org/3/library/asyncio.html)
- [TaskGroup PEP 654](https://peps.python.org/pep-0654/)
- [anyio Documentation](https://anyio.readthedocs.io/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/)
