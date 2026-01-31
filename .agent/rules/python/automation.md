# Python Automation & Scripting Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** Typer, Rich, httpx, Playwright
> **Priority:** P1 - Load for automation projects

---

You are an expert in Python automation and scripting.

## Key Principles

- Write robust, error-resistant scripts
- Use modern async patterns
- Make scripts configurable with CLI
- Implement proper logging with Rich
- Handle edge cases gracefully
- Document usage clearly

---

## Project Structure

```
automation/
├── src/
│   ├── __init__.py
│   ├── cli.py              # Typer CLI
│   ├── config.py           # Configuration
│   ├── scrapers/
│   │   ├── base.py
│   │   └── web_scraper.py
│   ├── tasks/
│   │   ├── file_ops.py
│   │   └── api_client.py
│   └── utils/
│       ├── logging.py
│       └── retry.py
├── scripts/
│   └── run_daily.py
├── tests/
├── pyproject.toml
└── README.md
```

---

## CLI with Typer

### Modern CLI Application
```python
# src/cli.py
from pathlib import Path
from typing import Annotated, Optional
import typer
from rich.console import Console
from rich.table import Table
from rich.progress import track
from rich import print as rprint

app = typer.Typer(
    name="automation",
    help="Python automation toolkit",
    add_completion=False,
)
console = Console()


@app.command()
def scrape(
    url: Annotated[str, typer.Argument(help="URL to scrape")],
    output: Annotated[Path, typer.Option("--output", "-o", help="Output file")] = Path("output.json"),
    verbose: Annotated[bool, typer.Option("--verbose", "-v", help="Verbose output")] = False,
    limit: Annotated[int, typer.Option("--limit", "-l", help="Max items")] = 100,
):
    """Scrape data from a website."""
    if verbose:
        console.print(f"[bold blue]Scraping:[/bold blue] {url}")
    
    # Simulate scraping with progress
    items = []
    for i in track(range(limit), description="Scraping..."):
        items.append({"id": i, "data": f"item_{i}"})
    
    # Save results
    import json
    output.write_text(json.dumps(items, indent=2))
    
    console.print(f"[bold green]✓[/bold green] Saved {len(items)} items to {output}")


@app.command()
def process(
    input_dir: Annotated[Path, typer.Argument(help="Input directory")],
    pattern: Annotated[str, typer.Option("--pattern", "-p")] = "*.csv",
    dry_run: Annotated[bool, typer.Option("--dry-run", help="Preview only")] = False,
):
    """Process files in a directory."""
    files = list(input_dir.glob(pattern))
    
    if not files:
        console.print("[yellow]No files found matching pattern[/yellow]")
        raise typer.Exit(1)
    
    # Show table of files
    table = Table(title="Files to Process")
    table.add_column("File", style="cyan")
    table.add_column("Size", justify="right", style="green")
    
    for file in files:
        size = f"{file.stat().st_size / 1024:.1f} KB"
        table.add_row(str(file.name), size)
    
    console.print(table)
    
    if dry_run:
        console.print("[yellow]Dry run - no changes made[/yellow]")
        return
    
    # Confirm
    if not typer.confirm("Proceed with processing?"):
        raise typer.Abort()
    
    # Process files
    for file in track(files, description="Processing..."):
        # Process each file
        pass
    
    console.print("[bold green]✓ Processing complete![/bold green]")


@app.command()
def schedule(
    task: Annotated[str, typer.Argument(help="Task to schedule")],
    interval: Annotated[str, typer.Option(help="Interval (e.g., '1h', '30m')")] = "1h",
):
    """Schedule a recurring task."""
    import schedule
    import time
    
    console.print(f"[bold]Scheduling {task} every {interval}[/bold]")
    
    def run_task():
        console.print(f"[dim]Running {task}...[/dim]")
    
    # Parse interval
    if interval.endswith("h"):
        schedule.every(int(interval[:-1])).hours.do(run_task)
    elif interval.endswith("m"):
        schedule.every(int(interval[:-1])).minutes.do(run_task)
    
    console.print("[green]Scheduler started. Press Ctrl+C to stop.[/green]")
    
    try:
        while True:
            schedule.run_pending()
            time.sleep(1)
    except KeyboardInterrupt:
        console.print("\n[yellow]Scheduler stopped[/yellow]")


if __name__ == "__main__":
    app()
```

---

## Configuration

### Pydantic Settings
```python
# src/config.py
from pathlib import Path
from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="APP_",
        extra="ignore",
    )
    
    # General
    debug: bool = False
    log_level: str = "INFO"
    
    # API
    api_key: SecretStr = Field(default=...)
    api_base_url: str = "https://api.example.com"
    api_timeout: int = 30
    
    # Database
    db_path: Path = Path("data/app.db")
    
    # Scraping
    user_agent: str = "Mozilla/5.0 (compatible; Bot/1.0)"
    rate_limit: float = 1.0  # seconds between requests
    max_retries: int = 3
    
    # Email
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: SecretStr = Field(default="")


settings = Settings()
```

---

## Logging with Rich

### Structured Logging
```python
# src/utils/logging.py
import logging
import sys
from pathlib import Path
from datetime import datetime
from rich.logging import RichHandler
from rich.console import Console

console = Console()


def setup_logging(
    level: str = "INFO",
    log_file: Path | None = None,
    json_format: bool = False,
) -> logging.Logger:
    """Setup logging with Rich handler."""
    
    # Create logger
    logger = logging.getLogger("automation")
    logger.setLevel(level)
    logger.handlers.clear()
    
    # Rich console handler
    console_handler = RichHandler(
        console=console,
        show_time=True,
        show_path=False,
        rich_tracebacks=True,
        tracebacks_show_locals=True,
    )
    console_handler.setLevel(level)
    logger.addHandler(console_handler)
    
    # File handler
    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        if json_format:
            import json
            
            class JsonFormatter(logging.Formatter):
                def format(self, record):
                    return json.dumps({
                        "timestamp": datetime.utcnow().isoformat(),
                        "level": record.levelname,
                        "message": record.getMessage(),
                        "module": record.module,
                        "function": record.funcName,
                    })
            
            file_handler = logging.FileHandler(log_file)
            file_handler.setFormatter(JsonFormatter())
        else:
            file_handler = logging.FileHandler(log_file)
            file_handler.setFormatter(logging.Formatter(
                "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            ))
        
        file_handler.setLevel(level)
        logger.addHandler(file_handler)
    
    return logger


# Usage
logger = setup_logging(level="INFO", log_file=Path("logs/app.log"))
logger.info("Application started")
logger.warning("This is a warning")
logger.error("This is an error", exc_info=True)
```

---

## Retry with Tenacity

### Retry Decorator
```python
# src/utils/retry.py
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
    before_sleep_log,
    after_log,
)
import logging
import httpx

logger = logging.getLogger(__name__)


# Basic retry
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type((httpx.HTTPError, ConnectionError)),
    before_sleep=before_sleep_log(logger, logging.WARNING),
    after=after_log(logger, logging.DEBUG),
)
def fetch_with_retry(url: str) -> dict:
    """Fetch URL with automatic retry."""
    response = httpx.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


# Async retry
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type((httpx.HTTPError, ConnectionError)),
)
async def async_fetch_with_retry(url: str) -> dict:
    """Async fetch with retry."""
    async with httpx.AsyncClient() as client:
        response = await client.get(url, timeout=30)
        response.raise_for_status()
        return response.json()


# Custom retry decorator factory
def with_retry(
    max_attempts: int = 3,
    min_wait: float = 1,
    max_wait: float = 60,
    exceptions: tuple = (Exception,),
):
    """Create a retry decorator with custom settings."""
    return retry(
        stop=stop_after_attempt(max_attempts),
        wait=wait_exponential(multiplier=1, min=min_wait, max=max_wait),
        retry=retry_if_exception_type(exceptions),
        before_sleep=before_sleep_log(logger, logging.WARNING),
    )


# Usage
@with_retry(max_attempts=5, exceptions=(httpx.HTTPError,))
def custom_fetch(url: str) -> str:
    response = httpx.get(url)
    response.raise_for_status()
    return response.text
```

---

## Web Scraping

### Modern Async Scraper
```python
# src/scrapers/web_scraper.py
import asyncio
from dataclasses import dataclass
from typing import AsyncIterator
import httpx
from selectolax.parser import HTMLParser
from rich.progress import Progress, TaskID
from tenacity import retry, stop_after_attempt, wait_exponential

from ..config import settings
from ..utils.logging import logger


@dataclass
class ScrapedItem:
    url: str
    title: str
    content: str
    metadata: dict


class AsyncWebScraper:
    """Async web scraper with rate limiting."""
    
    def __init__(
        self,
        rate_limit: float = 1.0,
        max_concurrent: int = 5,
        user_agent: str | None = None,
    ):
        self.rate_limit = rate_limit
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.headers = {
            "User-Agent": user_agent or settings.user_agent,
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "en-US,en;q=0.5",
        }
        self._last_request_time = 0
    
    async def _rate_limit(self):
        """Implement rate limiting."""
        import time
        current = time.time()
        elapsed = current - self._last_request_time
        if elapsed < self.rate_limit:
            await asyncio.sleep(self.rate_limit - elapsed)
        self._last_request_time = time.time()
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
    )
    async def fetch(self, client: httpx.AsyncClient, url: str) -> str:
        """Fetch URL content with retry."""
        async with self.semaphore:
            await self._rate_limit()
            response = await client.get(url, headers=self.headers)
            response.raise_for_status()
            return response.text
    
    def parse(self, html: str, url: str) -> ScrapedItem:
        """Parse HTML content."""
        tree = HTMLParser(html)
        
        # Extract title
        title_node = tree.css_first("h1") or tree.css_first("title")
        title = title_node.text().strip() if title_node else ""
        
        # Extract content
        content_node = tree.css_first("article") or tree.css_first("main")
        content = content_node.text().strip() if content_node else ""
        
        # Extract metadata
        metadata = {}
        for meta in tree.css("meta"):
            name = meta.attributes.get("name") or meta.attributes.get("property")
            content_attr = meta.attributes.get("content")
            if name and content_attr:
                metadata[name] = content_attr
        
        return ScrapedItem(
            url=url,
            title=title,
            content=content,
            metadata=metadata,
        )
    
    async def scrape_urls(
        self,
        urls: list[str],
        progress: Progress | None = None,
    ) -> AsyncIterator[ScrapedItem]:
        """Scrape multiple URLs."""
        async with httpx.AsyncClient(timeout=30) as client:
            task_id = None
            if progress:
                task_id = progress.add_task("Scraping", total=len(urls))
            
            for url in urls:
                try:
                    html = await self.fetch(client, url)
                    item = self.parse(html, url)
                    yield item
                    
                    if progress and task_id:
                        progress.update(task_id, advance=1)
                
                except Exception as e:
                    logger.error(f"Failed to scrape {url}: {e}")
                    continue


# Usage
async def main():
    from rich.progress import Progress
    
    scraper = AsyncWebScraper(rate_limit=0.5, max_concurrent=3)
    urls = [
        "https://example.com/page1",
        "https://example.com/page2",
        "https://example.com/page3",
    ]
    
    with Progress() as progress:
        async for item in scraper.scrape_urls(urls, progress):
            print(f"Scraped: {item.title}")


if __name__ == "__main__":
    asyncio.run(main())
```

---

## Browser Automation with Playwright

### Browser Scraper
```python
# src/scrapers/browser_scraper.py
import asyncio
from pathlib import Path
from dataclasses import dataclass
from playwright.async_api import async_playwright, Page, Browser


@dataclass
class PageData:
    url: str
    title: str
    content: str
    screenshot: bytes | None = None


class BrowserScraper:
    """Browser automation with Playwright."""
    
    def __init__(
        self,
        headless: bool = True,
        slow_mo: int = 0,
    ):
        self.headless = headless
        self.slow_mo = slow_mo
        self._browser: Browser | None = None
        self._playwright = None
    
    async def __aenter__(self):
        self._playwright = await async_playwright().start()
        self._browser = await self._playwright.chromium.launch(
            headless=self.headless,
            slow_mo=self.slow_mo,
        )
        return self
    
    async def __aexit__(self, *args):
        if self._browser:
            await self._browser.close()
        if self._playwright:
            await self._playwright.stop()
    
    async def scrape_page(
        self,
        url: str,
        wait_for: str | None = None,
        screenshot: bool = False,
    ) -> PageData:
        """Scrape a single page."""
        page = await self._browser.new_page()
        
        try:
            await page.goto(url, wait_until="networkidle")
            
            if wait_for:
                await page.wait_for_selector(wait_for)
            
            title = await page.title()
            content = await page.content()
            
            screenshot_data = None
            if screenshot:
                screenshot_data = await page.screenshot(full_page=True)
            
            return PageData(
                url=url,
                title=title,
                content=content,
                screenshot=screenshot_data,
            )
        finally:
            await page.close()
    
    async def fill_form(
        self,
        url: str,
        form_data: dict[str, str],
        submit_selector: str,
    ) -> str:
        """Fill and submit a form."""
        page = await self._browser.new_page()
        
        try:
            await page.goto(url)
            
            for selector, value in form_data.items():
                await page.fill(selector, value)
            
            await page.click(submit_selector)
            await page.wait_for_load_state("networkidle")
            
            return await page.content()
        finally:
            await page.close()
    
    async def login_and_scrape(
        self,
        login_url: str,
        username: str,
        password: str,
        target_url: str,
        username_selector: str = 'input[name="username"]',
        password_selector: str = 'input[name="password"]',
        submit_selector: str = 'button[type="submit"]',
    ) -> PageData:
        """Login and scrape authenticated page."""
        page = await self._browser.new_page()
        
        try:
            # Login
            await page.goto(login_url)
            await page.fill(username_selector, username)
            await page.fill(password_selector, password)
            await page.click(submit_selector)
            await page.wait_for_load_state("networkidle")
            
            # Navigate to target
            await page.goto(target_url)
            await page.wait_for_load_state("networkidle")
            
            return PageData(
                url=target_url,
                title=await page.title(),
                content=await page.content(),
            )
        finally:
            await page.close()


# Usage
async def main():
    async with BrowserScraper(headless=True) as scraper:
        # Simple scrape
        page = await scraper.scrape_page(
            "https://example.com",
            screenshot=True,
        )
        print(f"Title: {page.title}")
        
        if page.screenshot:
            Path("screenshot.png").write_bytes(page.screenshot)


if __name__ == "__main__":
    asyncio.run(main())
```

---

## File Operations

### Modern File Handling
```python
# src/tasks/file_ops.py
from pathlib import Path
import json
import csv
from typing import Iterator, Any
import aiofiles
import asyncio
from rich.progress import track


class FileProcessor:
    """Modern file operations."""
    
    @staticmethod
    def read_json(path: Path) -> dict:
        """Read JSON file."""
        return json.loads(path.read_text(encoding="utf-8"))
    
    @staticmethod
    def write_json(path: Path, data: Any, indent: int = 2) -> None:
        """Write JSON file."""
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps(data, indent=indent, ensure_ascii=False),
            encoding="utf-8"
        )
    
    @staticmethod
    def read_csv(path: Path) -> list[dict]:
        """Read CSV file as list of dicts."""
        with path.open(encoding="utf-8", newline="") as f:
            return list(csv.DictReader(f))
    
    @staticmethod
    def write_csv(path: Path, data: list[dict]) -> None:
        """Write list of dicts to CSV."""
        if not data:
            return
        
        path.parent.mkdir(parents=True, exist_ok=True)
        
        with path.open("w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=data[0].keys())
            writer.writeheader()
            writer.writerows(data)
    
    @staticmethod
    def iter_lines(path: Path, encoding: str = "utf-8") -> Iterator[str]:
        """Iterate over lines in a file."""
        with path.open(encoding=encoding) as f:
            for line in f:
                yield line.strip()
    
    @staticmethod
    async def async_read(path: Path) -> str:
        """Async file read."""
        async with aiofiles.open(path, encoding="utf-8") as f:
            return await f.read()
    
    @staticmethod
    async def async_write(path: Path, content: str) -> None:
        """Async file write."""
        path.parent.mkdir(parents=True, exist_ok=True)
        async with aiofiles.open(path, "w", encoding="utf-8") as f:
            await f.write(content)
    
    @staticmethod
    def batch_process(
        input_dir: Path,
        output_dir: Path,
        pattern: str = "*",
        transform: callable = None,
    ) -> int:
        """Batch process files."""
        files = list(input_dir.glob(pattern))
        processed = 0
        
        for file in track(files, description="Processing files..."):
            try:
                content = file.read_text(encoding="utf-8")
                
                if transform:
                    content = transform(content)
                
                output_path = output_dir / file.name
                output_path.parent.mkdir(parents=True, exist_ok=True)
                output_path.write_text(content, encoding="utf-8")
                
                processed += 1
            except Exception as e:
                print(f"Error processing {file}: {e}")
        
        return processed


# Async batch processing
async def async_batch_process(
    files: list[Path],
    transform: callable,
    max_concurrent: int = 10,
) -> list[Path]:
    """Async batch process files."""
    semaphore = asyncio.Semaphore(max_concurrent)
    results = []
    
    async def process_file(file: Path) -> Path | None:
        async with semaphore:
            try:
                content = await FileProcessor.async_read(file)
                transformed = transform(content)
                output = file.with_suffix(".processed")
                await FileProcessor.async_write(output, transformed)
                return output
            except Exception as e:
                print(f"Error: {e}")
                return None
    
    tasks = [process_file(f) for f in files]
    for result in await asyncio.gather(*tasks):
        if result:
            results.append(result)
    
    return results
```

---

## API Client

### Async API Client
```python
# src/tasks/api_client.py
from typing import Any
import httpx
from pydantic import BaseModel
from tenacity import retry, stop_after_attempt, wait_exponential

from ..config import settings


class APIClient:
    """Async API client with retry and auth."""
    
    def __init__(
        self,
        base_url: str,
        api_key: str | None = None,
        timeout: int = 30,
    ):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(min=1, max=10),
    )
    async def _request(
        self,
        method: str,
        endpoint: str,
        **kwargs,
    ) -> dict:
        """Make HTTP request."""
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            url = f"{self.base_url}/{endpoint.lstrip('/')}"
            response = await client.request(
                method,
                url,
                headers=self.headers,
                **kwargs,
            )
            response.raise_for_status()
            return response.json()
    
    async def get(self, endpoint: str, params: dict = None) -> dict:
        """GET request."""
        return await self._request("GET", endpoint, params=params)
    
    async def post(self, endpoint: str, data: dict) -> dict:
        """POST request."""
        return await self._request("POST", endpoint, json=data)
    
    async def put(self, endpoint: str, data: dict) -> dict:
        """PUT request."""
        return await self._request("PUT", endpoint, json=data)
    
    async def delete(self, endpoint: str) -> dict:
        """DELETE request."""
        return await self._request("DELETE", endpoint)
    
    async def paginated_get(
        self,
        endpoint: str,
        page_param: str = "page",
        limit_param: str = "limit",
        limit: int = 100,
    ) -> list[dict]:
        """Get all pages of a paginated endpoint."""
        all_results = []
        page = 1
        
        while True:
            params = {page_param: page, limit_param: limit}
            response = await self.get(endpoint, params=params)
            
            results = response.get("data", response.get("results", []))
            if not results:
                break
            
            all_results.extend(results)
            
            # Check if more pages
            if len(results) < limit:
                break
            
            page += 1
        
        return all_results


# Usage
async def main():
    client = APIClient(
        base_url="https://api.example.com/v1",
        api_key=settings.api_key.get_secret_value(),
    )
    
    # Single request
    user = await client.get("/users/1")
    
    # Paginated request
    all_users = await client.paginated_get("/users")
    
    # POST request
    new_user = await client.post("/users", {
        "name": "John",
        "email": "john@example.com",
    })


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

---

## Email Automation

### Email Sender
```python
# src/tasks/email_sender.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from pathlib import Path
from dataclasses import dataclass
from jinja2 import Template

from ..config import settings


@dataclass
class EmailMessage:
    to: str | list[str]
    subject: str
    body: str
    html: bool = False
    attachments: list[Path] = None
    cc: list[str] = None
    bcc: list[str] = None


class EmailSender:
    """Email sender with templates."""
    
    def __init__(
        self,
        smtp_host: str = None,
        smtp_port: int = None,
        username: str = None,
        password: str = None,
    ):
        self.smtp_host = smtp_host or settings.smtp_host
        self.smtp_port = smtp_port or settings.smtp_port
        self.username = username or settings.smtp_user
        self.password = password or settings.smtp_password.get_secret_value()
    
    def send(self, message: EmailMessage) -> bool:
        """Send an email."""
        msg = MIMEMultipart()
        msg["From"] = self.username
        msg["To"] = message.to if isinstance(message.to, str) else ", ".join(message.to)
        msg["Subject"] = message.subject
        
        if message.cc:
            msg["Cc"] = ", ".join(message.cc)
        
        # Body
        if message.html:
            msg.attach(MIMEText(message.body, "html"))
        else:
            msg.attach(MIMEText(message.body, "plain"))
        
        # Attachments
        if message.attachments:
            for file_path in message.attachments:
                part = MIMEBase("application", "octet-stream")
                part.set_payload(file_path.read_bytes())
                encoders.encode_base64(part)
                part.add_header(
                    "Content-Disposition",
                    f"attachment; filename={file_path.name}",
                )
                msg.attach(part)
        
        # Send
        try:
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                server.starttls()
                server.login(self.username, self.password)
                server.send_message(msg)
            return True
        except Exception as e:
            print(f"Failed to send email: {e}")
            return False
    
    def send_template(
        self,
        to: str | list[str],
        subject: str,
        template: str,
        context: dict,
        **kwargs,
    ) -> bool:
        """Send email from template."""
        body = Template(template).render(**context)
        
        message = EmailMessage(
            to=to,
            subject=subject,
            body=body,
            html=True,
            **kwargs,
        )
        
        return self.send(message)


# Usage
EMAIL_TEMPLATE = """
<html>
<body>
    <h1>Hello {{ name }}!</h1>
    <p>Your report for {{ date }} is ready.</p>
    <ul>
    {% for item in items %}
        <li>{{ item }}</li>
    {% endfor %}
    </ul>
</body>
</html>
"""

sender = EmailSender()
sender.send_template(
    to="user@example.com",
    subject="Daily Report",
    template=EMAIL_TEMPLATE,
    context={
        "name": "John",
        "date": "2024-01-15",
        "items": ["Item 1", "Item 2", "Item 3"],
    },
)
```

---

## Best Practices Checklist

- [ ] Use Typer for CLI applications
- [ ] Use Rich for beautiful output
- [ ] Use httpx for async HTTP requests
- [ ] Use Playwright for browser automation
- [ ] Use Tenacity for retry logic
- [ ] Use Pydantic for configuration
- [ ] Use aiofiles for async file I/O
- [ ] Implement proper logging
- [ ] Handle errors gracefully
- [ ] Write tests for automation scripts

---

**References:**
- [Typer Documentation](https://typer.tiangolo.com/)
- [Rich Documentation](https://rich.readthedocs.io/)
- [Playwright Python](https://playwright.dev/python/)
- [httpx Documentation](https://www.python-httpx.org/)
- [Tenacity](https://tenacity.readthedocs.io/)
