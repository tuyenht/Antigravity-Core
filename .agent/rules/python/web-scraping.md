# Python Web Scraping Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** httpx, selectolax, Playwright
> **Priority:** P1 - Load for web scraping projects

---

You are an expert in Python web scraping with modern tools.

## Key Principles

- Respect robots.txt and terms of service
- Implement rate limiting
- Handle errors gracefully with retries
- Use the right tool for the job
- Validate extracted data with Pydantic
- Store data efficiently

---

## Choosing the Right Tool

| Tool | Use Case | Performance |
|------|----------|-------------|
| **httpx + selectolax** | Static sites, high performance | ⚡ Fastest |
| **Playwright** | JavaScript-heavy, SPA | 🎯 Most reliable |
| **Scrapy** | Large-scale, complex crawls | 📊 Most scalable |
| **BeautifulSoup** | Simple parsing, learning | 📚 Easiest |

---

## Project Structure

```
scraper/
├── src/
│   ├── __init__.py
│   ├── config.py
│   ├── models.py            # Pydantic models
│   ├── scrapers/
│   │   ├── base.py          # Base scraper
│   │   ├── static.py        # httpx + selectolax
│   │   └── dynamic.py       # Playwright
│   ├── utils/
│   │   ├── retry.py
│   │   ├── rate_limiter.py
│   │   └── proxy.py
│   └── storage/
│       ├── csv_writer.py
│       └── database.py
├── data/
├── tests/
└── pyproject.toml
```

---

## httpx + selectolax (Fast Static Scraping)

### Basic Setup
```python
import httpx
from selectolax.parser import HTMLParser
from dataclasses import dataclass
from typing import Iterator


@dataclass
class Product:
    name: str
    price: float
    url: str
    in_stock: bool


class StaticScraper:
    """Fast static page scraper."""
    
    def __init__(
        self,
        rate_limit: float = 1.0,
        max_concurrent: int = 5,
    ):
        self.rate_limit = rate_limit
        self.headers = {
            "User-Agent": "Mozilla/5.0 (compatible; MyScraper/1.0)",
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "en-US,en;q=0.9",
        }
        self.client = httpx.Client(
            headers=self.headers,
            timeout=30.0,
            follow_redirects=True,
        )
    
    def fetch(self, url: str) -> HTMLParser:
        """Fetch and parse URL."""
        response = self.client.get(url)
        response.raise_for_status()
        return HTMLParser(response.text)
    
    def parse_product(self, tree: HTMLParser, url: str) -> Product:
        """Parse product from HTML."""
        name = tree.css_first("h1.product-title")
        price = tree.css_first("span.price")
        stock = tree.css_first("span.in-stock")
        
        return Product(
            name=name.text().strip() if name else "",
            price=float(price.text().replace("$", "")) if price else 0.0,
            url=url,
            in_stock=stock is not None,
        )
    
    def scrape_listing(self, url: str) -> Iterator[str]:
        """Extract product URLs from listing page."""
        tree = self.fetch(url)
        
        for link in tree.css("a.product-link"):
            href = link.attributes.get("href")
            if href:
                yield href
    
    def close(self):
        self.client.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, *args):
        self.close()


# Usage
with StaticScraper() as scraper:
    for product_url in scraper.scrape_listing("https://shop.example.com"):
        tree = scraper.fetch(product_url)
        product = scraper.parse_product(tree, product_url)
        print(f"{product.name}: ${product.price}")
```

### Async Scraping with httpx
```python
import asyncio
import httpx
from selectolax.parser import HTMLParser
from tenacity import retry, stop_after_attempt, wait_exponential


class AsyncScraper:
    """Async scraper with rate limiting."""
    
    def __init__(self, max_concurrent: int = 10, rate_limit: float = 0.5):
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.rate_limit = rate_limit
        self._last_request = 0
        self.headers = {
            "User-Agent": "Mozilla/5.0 (compatible; MyScraper/1.0)",
        }
    
    async def _rate_limit(self):
        """Implement rate limiting."""
        import time
        current = time.time()
        elapsed = current - self._last_request
        if elapsed < self.rate_limit:
            await asyncio.sleep(self.rate_limit - elapsed)
        self._last_request = time.time()
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(min=1, max=10),
    )
    async def fetch(self, client: httpx.AsyncClient, url: str) -> HTMLParser:
        """Fetch URL with retry."""
        async with self.semaphore:
            await self._rate_limit()
            response = await client.get(url, headers=self.headers)
            response.raise_for_status()
            return HTMLParser(response.text)
    
    async def scrape_many(self, urls: list[str]) -> list[dict]:
        """Scrape multiple URLs concurrently."""
        results = []
        
        async with httpx.AsyncClient(timeout=30) as client:
            async with asyncio.TaskGroup() as tg:
                tasks = [
                    tg.create_task(self.fetch(client, url))
                    for url in urls
                ]
            
            for url, task in zip(urls, tasks):
                try:
                    tree = task.result()
                    data = self.parse(tree, url)
                    results.append(data)
                except Exception as e:
                    print(f"Error scraping {url}: {e}")
        
        return results
    
    def parse(self, tree: HTMLParser, url: str) -> dict:
        """Parse HTML tree."""
        title = tree.css_first("h1")
        return {
            "url": url,
            "title": title.text().strip() if title else None,
        }


# Usage
async def main():
    scraper = AsyncScraper(max_concurrent=5, rate_limit=0.5)
    urls = [f"https://example.com/page/{i}" for i in range(100)]
    
    results = await scraper.scrape_many(urls)
    print(f"Scraped {len(results)} pages")


asyncio.run(main())
```

---

## selectolax Parsing

### CSS Selectors
```python
from selectolax.parser import HTMLParser

html = """
<html>
<body>
    <div class="products">
        <div class="product" data-id="1">
            <h2 class="title">Product 1</h2>
            <span class="price">$19.99</span>
            <a href="/product/1">View</a>
        </div>
        <div class="product" data-id="2">
            <h2 class="title">Product 2</h2>
            <span class="price">$29.99</span>
            <a href="/product/2">View</a>
        </div>
    </div>
</body>
</html>
"""

tree = HTMLParser(html)

# Single element
title = tree.css_first("h2.title")
print(title.text())  # "Product 1"

# Multiple elements
products = tree.css("div.product")
for product in products:
    name = product.css_first("h2.title").text()
    price = product.css_first("span.price").text()
    link = product.css_first("a").attributes.get("href")
    data_id = product.attributes.get("data-id")
    print(f"{name}: {price} ({link})")

# Extract all text
text = tree.body.text(separator=" ", strip=True)

# Remove unwanted elements
tree.strip_tags(["script", "style", "nav", "footer"])
clean_text = tree.body.text()
```

### XPath with parsel
```python
from parsel import Selector

html = "<html><body><div class='item'>Text</div></body></html>"
sel = Selector(text=html)

# XPath queries
items = sel.xpath("//div[@class='item']")
for item in items:
    text = item.xpath("./text()").get()
    
# CSS queries (also available)
items = sel.css("div.item")

# Extract with regex
prices = sel.css("span.price::text").re(r"\d+\.\d+")
```

---

## Playwright (Dynamic Content)

### Basic Browser Scraping
```python
import asyncio
from playwright.async_api import async_playwright, Page
from dataclasses import dataclass


@dataclass
class Article:
    title: str
    content: str
    author: str
    date: str


class PlaywrightScraper:
    """Browser-based scraper for dynamic content."""
    
    def __init__(self, headless: bool = True):
        self.headless = headless
        self._playwright = None
        self._browser = None
    
    async def __aenter__(self):
        self._playwright = await async_playwright().start()
        self._browser = await self._playwright.chromium.launch(
            headless=self.headless,
        )
        return self
    
    async def __aexit__(self, *args):
        await self._browser.close()
        await self._playwright.stop()
    
    async def new_page(self) -> Page:
        """Create new page with common settings."""
        context = await self._browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            viewport={"width": 1920, "height": 1080},
            locale="en-US",
        )
        return await context.new_page()
    
    async def scrape_article(self, url: str) -> Article:
        """Scrape article from URL."""
        page = await self.new_page()
        
        try:
            await page.goto(url, wait_until="networkidle")
            
            # Wait for content to load
            await page.wait_for_selector("article h1", timeout=10000)
            
            title = await page.text_content("article h1")
            content = await page.text_content("article .content")
            author = await page.text_content("article .author")
            date = await page.text_content("article time")
            
            return Article(
                title=title.strip() if title else "",
                content=content.strip() if content else "",
                author=author.strip() if author else "",
                date=date.strip() if date else "",
            )
        finally:
            await page.close()
    
    async def scrape_with_scroll(self, url: str) -> list[dict]:
        """Scrape infinite scroll page."""
        page = await self.new_page()
        items = []
        
        try:
            await page.goto(url, wait_until="networkidle")
            
            # Scroll until no new content
            previous_count = 0
            while True:
                # Extract current items
                current_items = await page.query_selector_all(".item")
                
                if len(current_items) == previous_count:
                    break
                
                previous_count = len(current_items)
                
                # Scroll to bottom
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                await page.wait_for_timeout(2000)
            
            # Extract all items
            for item in await page.query_selector_all(".item"):
                title = await item.text_content(".title")
                items.append({"title": title})
            
            return items
        finally:
            await page.close()
    
    async def handle_login(
        self,
        login_url: str,
        username: str,
        password: str,
        target_url: str,
    ) -> str:
        """Login and scrape protected page."""
        page = await self.new_page()
        
        try:
            # Go to login page
            await page.goto(login_url)
            
            # Fill login form
            await page.fill('input[name="username"]', username)
            await page.fill('input[name="password"]', password)
            await page.click('button[type="submit"]')
            
            # Wait for redirect
            await page.wait_for_url(lambda url: "login" not in url)
            
            # Navigate to target
            await page.goto(target_url, wait_until="networkidle")
            
            return await page.content()
        finally:
            await page.close()


# Usage
async def main():
    async with PlaywrightScraper(headless=True) as scraper:
        article = await scraper.scrape_article("https://news.example.com/article/1")
        print(f"Title: {article.title}")


asyncio.run(main())
```

### Network Interception
```python
async def scrape_with_api_interception(url: str) -> list[dict]:
    """Intercept API calls instead of parsing HTML."""
    captured_data = []
    
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        
        # Intercept API responses
        async def handle_response(response):
            if "/api/products" in response.url:
                try:
                    data = await response.json()
                    captured_data.extend(data.get("items", []))
                except:
                    pass
        
        page.on("response", handle_response)
        
        # Navigate and trigger API calls
        await page.goto(url)
        await page.wait_for_timeout(3000)
        
        # Scroll to load more
        for _ in range(5):
            await page.keyboard.press("End")
            await page.wait_for_timeout(1000)
        
        await browser.close()
    
    return captured_data
```

### Stealth Mode
```python
from playwright.async_api import async_playwright


async def stealth_scrape(url: str):
    """Scrape with stealth settings."""
    async with async_playwright() as p:
        browser = await p.chromium.launch(
            headless=True,
            args=[
                "--disable-blink-features=AutomationControlled",
            ],
        )
        
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            viewport={"width": 1920, "height": 1080},
            locale="en-US",
            timezone_id="America/New_York",
            geolocation={"latitude": 40.7128, "longitude": -74.0060},
            permissions=["geolocation"],
        )
        
        page = await context.new_page()
        
        # Remove webdriver flag
        await page.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined,
            });
        """)
        
        # Random mouse movements
        await page.goto(url)
        await page.mouse.move(100, 100)
        await page.wait_for_timeout(500)
        await page.mouse.move(200, 300)
        
        content = await page.content()
        await browser.close()
        
        return content
```

---

## Data Models with Pydantic

### Validated Scraping
```python
from pydantic import BaseModel, Field, HttpUrl, field_validator
from datetime import datetime
from typing import Optional


class ScrapedProduct(BaseModel):
    """Validated product data."""
    
    name: str = Field(min_length=1)
    price: float = Field(ge=0)
    currency: str = "USD"
    url: HttpUrl
    sku: Optional[str] = None
    in_stock: bool = True
    scraped_at: datetime = Field(default_factory=datetime.utcnow)
    
    @field_validator("name")
    @classmethod
    def clean_name(cls, v: str) -> str:
        return v.strip().replace("\n", " ")
    
    @field_validator("price", mode="before")
    @classmethod
    def parse_price(cls, v) -> float:
        if isinstance(v, str):
            # Remove currency symbols and parse
            cleaned = v.replace("$", "").replace(",", "").strip()
            return float(cleaned)
        return v


class ScrapedPage(BaseModel):
    """Container for scraped data."""
    
    url: HttpUrl
    products: list[ScrapedProduct] = []
    next_page: Optional[HttpUrl] = None
    error: Optional[str] = None


# Usage
def parse_product_card(html_element, base_url: str) -> ScrapedProduct:
    """Parse product with validation."""
    try:
        return ScrapedProduct(
            name=html_element.css_first(".name").text(),
            price=html_element.css_first(".price").text(),
            url=f"{base_url}{html_element.css_first('a').attributes['href']}",
            sku=html_element.css_first(".sku").text() if html_element.css_first(".sku") else None,
        )
    except Exception as e:
        raise ValueError(f"Failed to parse product: {e}")
```

---

## Rate Limiting

### Token Bucket Rate Limiter
```python
import asyncio
import time
from dataclasses import dataclass


@dataclass
class RateLimiter:
    """Token bucket rate limiter."""
    
    rate: float  # requests per second
    burst: int   # max burst size
    
    def __post_init__(self):
        self._tokens = self.burst
        self._last_update = time.monotonic()
        self._lock = asyncio.Lock()
    
    async def acquire(self):
        """Acquire permission to make a request."""
        async with self._lock:
            now = time.monotonic()
            time_passed = now - self._last_update
            self._tokens = min(
                self.burst,
                self._tokens + time_passed * self.rate
            )
            self._last_update = now
            
            if self._tokens < 1:
                sleep_time = (1 - self._tokens) / self.rate
                await asyncio.sleep(sleep_time)
                self._tokens = 0
            else:
                self._tokens -= 1


# Usage
limiter = RateLimiter(rate=2.0, burst=5)  # 2 req/sec, burst of 5

async def fetch_with_limit(url: str):
    await limiter.acquire()
    # Make request
```

---

## Proxy Rotation

### Proxy Manager
```python
import random
from dataclasses import dataclass
from typing import Optional
import httpx


@dataclass
class Proxy:
    host: str
    port: int
    username: Optional[str] = None
    password: Optional[str] = None
    failures: int = 0
    
    @property
    def url(self) -> str:
        if self.username:
            return f"http://{self.username}:{self.password}@{self.host}:{self.port}"
        return f"http://{self.host}:{self.port}"


class ProxyManager:
    """Rotating proxy manager."""
    
    def __init__(self, proxies: list[Proxy], max_failures: int = 3):
        self.proxies = proxies
        self.max_failures = max_failures
        self._current_index = 0
    
    def get_proxy(self) -> Optional[Proxy]:
        """Get next working proxy."""
        available = [p for p in self.proxies if p.failures < self.max_failures]
        
        if not available:
            # Reset all proxies
            for p in self.proxies:
                p.failures = 0
            available = self.proxies
        
        return random.choice(available) if available else None
    
    def report_failure(self, proxy: Proxy):
        """Report proxy failure."""
        proxy.failures += 1
    
    def report_success(self, proxy: Proxy):
        """Report proxy success."""
        proxy.failures = max(0, proxy.failures - 1)


# Usage
proxies = [
    Proxy("proxy1.example.com", 8080, "user", "pass"),
    Proxy("proxy2.example.com", 8080, "user", "pass"),
]

manager = ProxyManager(proxies)

async def fetch_with_proxy(url: str):
    proxy = manager.get_proxy()
    
    try:
        async with httpx.AsyncClient(proxy=proxy.url if proxy else None) as client:
            response = await client.get(url)
            if proxy:
                manager.report_success(proxy)
            return response
    except Exception as e:
        if proxy:
            manager.report_failure(proxy)
        raise
```

---

## Scrapy Spider

### Modern Scrapy Spider
```python
import scrapy
from scrapy.http import Response
from pydantic import BaseModel, HttpUrl


class ProductItem(BaseModel):
    name: str
    price: float
    url: HttpUrl


class ProductSpider(scrapy.Spider):
    name = "products"
    allowed_domains = ["shop.example.com"]
    start_urls = ["https://shop.example.com/products"]
    
    custom_settings = {
        "CONCURRENT_REQUESTS": 8,
        "DOWNLOAD_DELAY": 0.5,
        "AUTOTHROTTLE_ENABLED": True,
        "AUTOTHROTTLE_START_DELAY": 1,
        "AUTOTHROTTLE_MAX_DELAY": 10,
        "ROBOTSTXT_OBEY": True,
    }
    
    def parse(self, response: Response):
        """Parse listing page."""
        # Extract product links
        for product in response.css("div.product"):
            product_url = product.css("a::attr(href)").get()
            
            if product_url:
                yield response.follow(
                    product_url,
                    callback=self.parse_product,
                )
        
        # Follow pagination
        next_page = response.css("a.next-page::attr(href)").get()
        if next_page:
            yield response.follow(next_page, callback=self.parse)
    
    def parse_product(self, response: Response):
        """Parse product detail page."""
        try:
            item = ProductItem(
                name=response.css("h1.title::text").get("").strip(),
                price=float(
                    response.css("span.price::text")
                    .get("")
                    .replace("$", "")
                    .strip() or 0
                ),
                url=response.url,
            )
            yield item.model_dump()
        except Exception as e:
            self.logger.error(f"Error parsing {response.url}: {e}")
```

---

## Data Storage

### Efficient CSV Writing
```python
import csv
from pathlib import Path
from typing import Iterator
from pydantic import BaseModel


class CSVWriter:
    """Efficient CSV writer for scraped data."""
    
    def __init__(self, path: Path, model: type[BaseModel]):
        self.path = path
        self.model = model
        self.fieldnames = list(model.model_fields.keys())
        self._file = None
        self._writer = None
    
    def __enter__(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._file = open(self.path, "w", newline="", encoding="utf-8")
        self._writer = csv.DictWriter(self._file, fieldnames=self.fieldnames)
        self._writer.writeheader()
        return self
    
    def __exit__(self, *args):
        if self._file:
            self._file.close()
    
    def write(self, item: BaseModel):
        """Write single item."""
        self._writer.writerow(item.model_dump())
    
    def write_many(self, items: Iterator[BaseModel]):
        """Write multiple items."""
        for item in items:
            self.write(item)


# Usage
with CSVWriter(Path("data/products.csv"), ScrapedProduct) as writer:
    for product in products:
        writer.write(product)
```

### SQLite Storage
```python
import sqlite3
from pathlib import Path
from contextlib import contextmanager
from pydantic import BaseModel


class SQLiteStorage:
    """SQLite storage for scraped data."""
    
    def __init__(self, db_path: Path):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()
    
    def _init_db(self):
        with self._connection() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS products (
                    id INTEGER PRIMARY KEY,
                    name TEXT NOT NULL,
                    price REAL,
                    url TEXT UNIQUE,
                    sku TEXT,
                    scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
    
    @contextmanager
    def _connection(self):
        conn = sqlite3.connect(self.db_path)
        try:
            yield conn
            conn.commit()
        finally:
            conn.close()
    
    def insert(self, product: ScrapedProduct):
        """Insert or update product."""
        with self._connection() as conn:
            conn.execute("""
                INSERT OR REPLACE INTO products (name, price, url, sku, scraped_at)
                VALUES (?, ?, ?, ?, ?)
            """, (
                product.name,
                product.price,
                str(product.url),
                product.sku,
                product.scraped_at,
            ))
    
    def get_all(self) -> list[dict]:
        """Get all products."""
        with self._connection() as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.execute("SELECT * FROM products")
            return [dict(row) for row in cursor.fetchall()]
```

---

## Best Practices Checklist

- [ ] Check robots.txt before scraping
- [ ] Use httpx + selectolax for static sites
- [ ] Use Playwright for JavaScript-heavy sites
- [ ] Implement rate limiting
- [ ] Use proxy rotation for large-scale scraping
- [ ] Validate data with Pydantic
- [ ] Handle errors with retries (Tenacity)
- [ ] Store data efficiently (CSV, SQLite)
- [ ] Monitor scraper health and errors
- [ ] Respect website terms of service

---

**References:**
- [httpx Documentation](https://www.python-httpx.org/)
- [selectolax Documentation](https://selectolax.readthedocs.io/)
- [Playwright Python](https://playwright.dev/python/)
- [Scrapy Documentation](https://docs.scrapy.org/)
