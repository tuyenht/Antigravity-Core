# Python CLI Development Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** Typer, Rich, Click
> **Priority:** P1 - Load for CLI projects

---

You are an expert in Python CLI development with Typer and Rich.

## Key Principles

- Make CLIs intuitive and user-friendly
- Use Typer for type-hinted CLIs
- Use Rich for beautiful terminal output
- Follow Unix philosophy
- Provide helpful error messages
- Support both interactive and non-interactive modes

---

## Project Structure

```
my-cli/
├── src/
│   └── mycli/
│       ├── __init__.py
│       ├── main.py           # Entry point
│       ├── cli.py            # CLI commands
│       ├── commands/
│       │   ├── __init__.py
│       │   ├── users.py
│       │   └── config.py
│       ├── utils/
│       │   ├── console.py    # Rich console
│       │   └── config.py     # Config handling
│       └── models.py
├── tests/
│   ├── conftest.py
│   └── test_cli.py
├── pyproject.toml
└── README.md
```

---

## Typer (Modern CLI)

### Basic CLI Application
```python
# src/mycli/main.py
import typer
from typing import Annotated, Optional
from pathlib import Path
from enum import Enum

from rich.console import Console
from rich.table import Table


app = typer.Typer(
    name="mycli",
    help="My awesome CLI application",
    add_completion=True,
    rich_markup_mode="rich",
)

console = Console()


class OutputFormat(str, Enum):
    json = "json"
    table = "table"
    csv = "csv"


@app.command()
def hello(
    name: Annotated[str, typer.Argument(help="Name to greet")],
    greeting: Annotated[str, typer.Option("--greeting", "-g", help="Greeting to use")] = "Hello",
    times: Annotated[int, typer.Option("--times", "-t", help="Number of times")] = 1,
    loud: Annotated[bool, typer.Option("--loud", "-l", help="Shout the greeting")] = False,
):
    """
    Say hello to NAME.
    
    This is a simple command that greets the user.
    """
    message = f"{greeting}, {name}!"
    
    if loud:
        message = message.upper()
    
    for _ in range(times):
        console.print(f"[bold green]{message}[/bold green]")


@app.command()
def process(
    input_file: Annotated[Path, typer.Argument(
        exists=True,
        file_okay=True,
        dir_okay=False,
        readable=True,
        help="Input file to process",
    )],
    output_file: Annotated[Optional[Path], typer.Option(
        "--output", "-o",
        help="Output file (default: stdout)",
    )] = None,
    format: Annotated[OutputFormat, typer.Option(
        "--format", "-f",
        help="Output format",
    )] = OutputFormat.table,
    verbose: Annotated[bool, typer.Option(
        "--verbose", "-v",
        help="Enable verbose output",
    )] = False,
):
    """
    Process INPUT_FILE and output results.
    
    Supports multiple output formats: JSON, Table, CSV.
    """
    if verbose:
        console.print(f"[dim]Processing {input_file}...[/dim]")
    
    # Process file
    data = process_data(input_file)
    
    # Output
    if format == OutputFormat.json:
        import json
        output = json.dumps(data, indent=2)
    elif format == OutputFormat.table:
        output = format_as_table(data)
    else:
        output = format_as_csv(data)
    
    if output_file:
        output_file.write_text(output)
        console.print(f"[green]✓[/green] Saved to {output_file}")
    else:
        console.print(output)


@app.callback()
def main(
    version: Annotated[bool, typer.Option(
        "--version", "-V",
        help="Show version and exit",
    )] = False,
    verbose: Annotated[bool, typer.Option(
        "--verbose", "-v",
        help="Enable verbose output",
    )] = False,
):
    """
    My CLI application for doing awesome things.
    
    Use --help on any command for more information.
    """
    if version:
        console.print("mycli version 1.0.0")
        raise typer.Exit()


if __name__ == "__main__":
    app()
```

### Command Groups
```python
# src/mycli/commands/users.py
import typer
from typing import Annotated, Optional
from rich.console import Console
from rich.table import Table

app = typer.Typer(help="User management commands")
console = Console()


@app.command("list")
def list_users(
    limit: Annotated[int, typer.Option("--limit", "-l")] = 10,
    active_only: Annotated[bool, typer.Option("--active")] = False,
):
    """List all users."""
    users = fetch_users(limit=limit, active_only=active_only)
    
    table = Table(title="Users")
    table.add_column("ID", style="cyan")
    table.add_column("Name", style="green")
    table.add_column("Email")
    table.add_column("Status")
    
    for user in users:
        status = "[green]Active[/green]" if user["active"] else "[red]Inactive[/red]"
        table.add_row(
            str(user["id"]),
            user["name"],
            user["email"],
            status,
        )
    
    console.print(table)


@app.command()
def create(
    name: Annotated[str, typer.Argument(help="User name")],
    email: Annotated[str, typer.Option("--email", "-e", prompt=True)],
    password: Annotated[str, typer.Option(
        "--password", "-p",
        prompt=True,
        confirmation_prompt=True,
        hide_input=True,
    )],
    admin: Annotated[bool, typer.Option("--admin")] = False,
):
    """Create a new user."""
    with console.status("[bold green]Creating user..."):
        user = create_user(name=name, email=email, password=password, admin=admin)
    
    console.print(f"[green]✓[/green] Created user: {user['id']}")


@app.command()
def delete(
    user_id: Annotated[int, typer.Argument(help="User ID to delete")],
    force: Annotated[bool, typer.Option("--force", "-f")] = False,
):
    """Delete a user by ID."""
    if not force:
        confirm = typer.confirm(f"Delete user {user_id}?")
        if not confirm:
            console.print("[yellow]Cancelled[/yellow]")
            raise typer.Exit()
    
    delete_user(user_id)
    console.print(f"[green]✓[/green] Deleted user {user_id}")


# src/mycli/commands/config.py
import typer
from typing import Annotated
from pathlib import Path
from rich.console import Console
from rich.syntax import Syntax

app = typer.Typer(help="Configuration commands")
console = Console()


@app.command()
def show():
    """Show current configuration."""
    config = load_config()
    
    import yaml
    config_yaml = yaml.dump(config, default_flow_style=False)
    
    syntax = Syntax(config_yaml, "yaml", theme="monokai")
    console.print(syntax)


@app.command("set")
def set_value(
    key: Annotated[str, typer.Argument(help="Config key (dot notation)")],
    value: Annotated[str, typer.Argument(help="Value to set")],
):
    """Set a configuration value."""
    update_config(key, value)
    console.print(f"[green]✓[/green] Set {key} = {value}")


@app.command()
def init(
    force: Annotated[bool, typer.Option("--force", "-f")] = False,
):
    """Initialize configuration file."""
    config_path = get_config_path()
    
    if config_path.exists() and not force:
        console.print("[yellow]Config already exists. Use --force to overwrite.[/yellow]")
        raise typer.Exit(1)
    
    create_default_config(config_path)
    console.print(f"[green]✓[/green] Created config at {config_path}")


# Main CLI - Register groups
# src/mycli/cli.py
import typer
from .commands import users, config

app = typer.Typer()
app.add_typer(users.app, name="users")
app.add_typer(config.app, name="config")
```

---

## Rich Terminal Output

### Console Utilities
```python
# src/mycli/utils/console.py
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import (
    Progress,
    SpinnerColumn,
    TextColumn,
    BarColumn,
    TaskProgressColumn,
    TimeRemainingColumn,
)
from rich.prompt import Prompt, Confirm, IntPrompt
from rich.syntax import Syntax
from rich.tree import Tree
from rich.live import Live
from contextlib import contextmanager
from typing import Any, Iterator


console = Console()
error_console = Console(stderr=True)


def print_success(message: str):
    """Print success message."""
    console.print(f"[bold green]✓[/bold green] {message}")


def print_error(message: str):
    """Print error message."""
    error_console.print(f"[bold red]✗[/bold red] {message}")


def print_warning(message: str):
    """Print warning message."""
    console.print(f"[bold yellow]⚠[/bold yellow] {message}")


def print_info(message: str):
    """Print info message."""
    console.print(f"[bold blue]ℹ[/bold blue] {message}")


def print_table(
    data: list[dict],
    title: str | None = None,
    columns: list[str] | None = None,
):
    """Print data as a table."""
    if not data:
        console.print("[dim]No data[/dim]")
        return
    
    table = Table(title=title)
    
    # Auto-detect columns from first row
    cols = columns or list(data[0].keys())
    
    for col in cols:
        table.add_column(col.title(), style="cyan")
    
    for row in data:
        table.add_row(*[str(row.get(col, "")) for col in cols])
    
    console.print(table)


def print_json(data: Any):
    """Print data as formatted JSON."""
    import json
    console.print_json(json.dumps(data))


def print_code(code: str, language: str = "python"):
    """Print syntax-highlighted code."""
    syntax = Syntax(code, language, theme="monokai", line_numbers=True)
    console.print(syntax)


def print_panel(content: str, title: str | None = None):
    """Print content in a panel."""
    panel = Panel(content, title=title)
    console.print(panel)


def print_tree(data: dict, title: str = "Tree"):
    """Print data as a tree."""
    tree = Tree(title)
    
    def add_nodes(node, d):
        for key, value in d.items():
            if isinstance(value, dict):
                branch = node.add(f"[bold]{key}[/bold]")
                add_nodes(branch, value)
            else:
                node.add(f"{key}: [green]{value}[/green]")
    
    add_nodes(tree, data)
    console.print(tree)


@contextmanager
def progress_bar(description: str = "Processing"):
    """Context manager for progress bar."""
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        TimeRemainingColumn(),
        console=console,
    ) as progress:
        yield progress


@contextmanager
def spinner(description: str = "Loading"):
    """Context manager for spinner."""
    with console.status(f"[bold green]{description}...") as status:
        yield status


def prompt_text(
    message: str,
    default: str | None = None,
    password: bool = False,
) -> str:
    """Prompt for text input."""
    return Prompt.ask(message, default=default, password=password)


def prompt_confirm(message: str, default: bool = False) -> bool:
    """Prompt for confirmation."""
    return Confirm.ask(message, default=default)


def prompt_int(message: str, default: int | None = None) -> int:
    """Prompt for integer input."""
    return IntPrompt.ask(message, default=default)


def prompt_choice(
    message: str,
    choices: list[str],
    default: str | None = None,
) -> str:
    """Prompt with choices."""
    return Prompt.ask(message, choices=choices, default=default)


# Usage
def demo():
    # Table
    users = [
        {"id": 1, "name": "Alice", "role": "Admin"},
        {"id": 2, "name": "Bob", "role": "User"},
    ]
    print_table(users, title="Users")
    
    # Progress
    with progress_bar("Downloading") as progress:
        task = progress.add_task("Downloading files...", total=100)
        for i in range(100):
            import time
            time.sleep(0.01)
            progress.update(task, advance=1)
    
    # Spinner
    with spinner("Loading data"):
        import time
        time.sleep(2)
    
    print_success("Done!")
```

### Live Display
```python
from rich.live import Live
from rich.table import Table
import time


def live_dashboard():
    """Real-time updating dashboard."""
    
    def generate_table() -> Table:
        table = Table(title="Live Stats")
        table.add_column("Metric")
        table.add_column("Value")
        
        import random
        table.add_row("CPU", f"{random.randint(10, 90)}%")
        table.add_row("Memory", f"{random.randint(20, 80)}%")
        table.add_row("Requests/s", f"{random.randint(100, 500)}")
        
        return table
    
    with Live(generate_table(), refresh_per_second=2) as live:
        for _ in range(20):
            time.sleep(0.5)
            live.update(generate_table())
```

---

## Interactive Mode

### REPL with Prompt Toolkit
```python
from prompt_toolkit import PromptSession
from prompt_toolkit.completion import WordCompleter, FuzzyCompleter
from prompt_toolkit.history import FileHistory
from prompt_toolkit.auto_suggest import AutoSuggestFromHistory
from prompt_toolkit.styles import Style
from rich.console import Console
from pathlib import Path


class InteractiveCLI:
    """Interactive REPL for CLI."""
    
    def __init__(self):
        self.console = Console()
        
        # Command completer
        commands = ["help", "list", "create", "delete", "config", "exit", "quit"]
        self.completer = FuzzyCompleter(WordCompleter(commands))
        
        # History file
        history_path = Path.home() / ".mycli_history"
        self.history = FileHistory(str(history_path))
        
        # Style
        self.style = Style.from_dict({
            "prompt": "bold green",
        })
        
        # Session
        self.session = PromptSession(
            completer=self.completer,
            history=self.history,
            auto_suggest=AutoSuggestFromHistory(),
            style=self.style,
        )
        
        # Commands
        self.commands = {
            "help": self.cmd_help,
            "list": self.cmd_list,
            "create": self.cmd_create,
            "config": self.cmd_config,
            "exit": self.cmd_exit,
            "quit": self.cmd_exit,
        }
    
    def run(self):
        """Run interactive mode."""
        self.console.print("[bold]Interactive Mode[/bold]")
        self.console.print("Type 'help' for commands, 'exit' to quit\n")
        
        while True:
            try:
                user_input = self.session.prompt("mycli> ")
                
                if not user_input.strip():
                    continue
                
                parts = user_input.strip().split()
                cmd = parts[0].lower()
                args = parts[1:]
                
                if cmd in self.commands:
                    self.commands[cmd](*args)
                else:
                    self.console.print(f"[red]Unknown command: {cmd}[/red]")
                    
            except KeyboardInterrupt:
                continue
            except EOFError:
                break
    
    def cmd_help(self, *args):
        """Show help."""
        help_text = """
Available commands:
  help    - Show this help
  list    - List items
  create  - Create new item
  config  - Show configuration
  exit    - Exit interactive mode
        """
        self.console.print(help_text)
    
    def cmd_list(self, *args):
        """List command."""
        self.console.print("[dim]Listing items...[/dim]")
    
    def cmd_create(self, *args):
        """Create command."""
        if not args:
            self.console.print("[yellow]Usage: create <name>[/yellow]")
            return
        self.console.print(f"[green]Created: {args[0]}[/green]")
    
    def cmd_config(self, *args):
        """Config command."""
        self.console.print("[dim]Configuration...[/dim]")
    
    def cmd_exit(self, *args):
        """Exit command."""
        self.console.print("[yellow]Goodbye![/yellow]")
        raise EOFError


# Typer command for interactive mode
@app.command()
def repl():
    """Start interactive REPL mode."""
    cli = InteractiveCLI()
    cli.run()
```

---

## Configuration Management

### Config Handler
```python
# src/mycli/utils/config.py
from pathlib import Path
from typing import Any
import tomllib
import tomli_w
from pydantic import BaseModel
from pydantic_settings import BaseSettings, SettingsConfigDict


class AppConfig(BaseModel):
    """Application configuration."""
    
    api_url: str = "https://api.example.com"
    api_key: str | None = None
    timeout: int = 30
    verbose: bool = False
    output_format: str = "table"


class Settings(BaseSettings):
    """Settings with environment variable support."""
    
    model_config = SettingsConfigDict(
        env_prefix="MYCLI_",
        env_file=".env",
    )
    
    config_path: Path = Path.home() / ".config" / "mycli" / "config.toml"
    debug: bool = False
    

def get_config_path() -> Path:
    """Get configuration file path."""
    # XDG Base Directory
    xdg_config = Path(
        os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")
    )
    return xdg_config / "mycli" / "config.toml"


def load_config() -> AppConfig:
    """Load configuration from file."""
    config_path = get_config_path()
    
    if not config_path.exists():
        return AppConfig()
    
    with open(config_path, "rb") as f:
        data = tomllib.load(f)
    
    return AppConfig(**data)


def save_config(config: AppConfig):
    """Save configuration to file."""
    config_path = get_config_path()
    config_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(config_path, "wb") as f:
        tomli_w.dump(config.model_dump(), f)


def update_config(key: str, value: Any):
    """Update a specific config key."""
    config = load_config()
    
    # Support dot notation
    keys = key.split(".")
    data = config.model_dump()
    
    current = data
    for k in keys[:-1]:
        current = current.setdefault(k, {})
    
    current[keys[-1]] = value
    
    new_config = AppConfig(**data)
    save_config(new_config)


def create_default_config(path: Path):
    """Create default configuration file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    
    default_config = AppConfig()
    
    with open(path, "wb") as f:
        tomli_w.dump(default_config.model_dump(), f)
```

---

## Error Handling

### Custom Exceptions
```python
# src/mycli/exceptions.py
import typer
from rich.console import Console


console = Console(stderr=True)


class CLIError(Exception):
    """Base CLI error."""
    
    def __init__(self, message: str, exit_code: int = 1):
        self.message = message
        self.exit_code = exit_code
        super().__init__(message)


class ValidationError(CLIError):
    """Validation error."""
    pass


class ConfigError(CLIError):
    """Configuration error."""
    pass


class APIError(CLIError):
    """API error."""
    pass


def handle_error(error: Exception, debug: bool = False):
    """Handle and display error."""
    if isinstance(error, CLIError):
        console.print(f"[bold red]Error:[/bold red] {error.message}")
        raise typer.Exit(error.exit_code)
    
    if debug:
        console.print_exception()
    else:
        console.print(f"[bold red]Error:[/bold red] {str(error)}")
    
    raise typer.Exit(1)


# Error handling decorator
from functools import wraps


def cli_error_handler(func):
    """Decorator for CLI error handling."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except CLIError as e:
            console.print(f"[bold red]Error:[/bold red] {e.message}")
            raise typer.Exit(e.exit_code)
        except KeyboardInterrupt:
            console.print("\n[yellow]Interrupted[/yellow]")
            raise typer.Exit(130)
        except Exception as e:
            console.print(f"[bold red]Unexpected error:[/bold red] {e}")
            raise typer.Exit(1)
    
    return wrapper


# Usage
@app.command()
@cli_error_handler
def risky_command():
    """Command with error handling."""
    # This will be caught and handled
    raise ValidationError("Invalid input")
```

---

## Testing

### CLI Testing
```python
# tests/test_cli.py
import pytest
from typer.testing import CliRunner
from mycli.main import app
from pathlib import Path


runner = CliRunner()


class TestHelloCommand:
    """Tests for hello command."""
    
    def test_hello_basic(self):
        """Test basic hello."""
        result = runner.invoke(app, ["hello", "World"])
        
        assert result.exit_code == 0
        assert "Hello, World!" in result.stdout
    
    def test_hello_with_greeting(self):
        """Test hello with custom greeting."""
        result = runner.invoke(app, ["hello", "World", "--greeting", "Hi"])
        
        assert result.exit_code == 0
        assert "Hi, World!" in result.stdout
    
    def test_hello_loud(self):
        """Test loud hello."""
        result = runner.invoke(app, ["hello", "World", "--loud"])
        
        assert result.exit_code == 0
        assert "HELLO, WORLD!" in result.stdout
    
    def test_hello_times(self):
        """Test hello multiple times."""
        result = runner.invoke(app, ["hello", "World", "--times", "3"])
        
        assert result.exit_code == 0
        assert result.stdout.count("Hello, World!") == 3


class TestProcessCommand:
    """Tests for process command."""
    
    def test_process_file(self, tmp_path: Path):
        """Test processing a file."""
        # Create test file
        input_file = tmp_path / "input.txt"
        input_file.write_text("test data")
        
        result = runner.invoke(app, ["process", str(input_file)])
        
        assert result.exit_code == 0
    
    def test_process_nonexistent_file(self):
        """Test processing nonexistent file."""
        result = runner.invoke(app, ["process", "nonexistent.txt"])
        
        assert result.exit_code != 0
    
    def test_process_with_output(self, tmp_path: Path):
        """Test processing with output file."""
        input_file = tmp_path / "input.txt"
        input_file.write_text("test data")
        output_file = tmp_path / "output.txt"
        
        result = runner.invoke(app, [
            "process",
            str(input_file),
            "--output", str(output_file),
        ])
        
        assert result.exit_code == 0
        assert output_file.exists()


class TestUserCommands:
    """Tests for user commands."""
    
    def test_user_list(self):
        """Test user list."""
        result = runner.invoke(app, ["users", "list"])
        
        assert result.exit_code == 0
    
    def test_user_create(self):
        """Test user creation."""
        result = runner.invoke(app, [
            "users", "create", "testuser",
            "--email", "test@example.com",
            "--password", "password123",
        ])
        
        assert result.exit_code == 0
    
    def test_user_delete_with_confirm(self):
        """Test user deletion with confirmation."""
        result = runner.invoke(
            app,
            ["users", "delete", "1"],
            input="y\n",
        )
        
        assert result.exit_code == 0


class TestConfigCommands:
    """Tests for config commands."""
    
    def test_config_show(self):
        """Test config show."""
        result = runner.invoke(app, ["config", "show"])
        
        assert result.exit_code == 0
    
    def test_config_set(self):
        """Test config set."""
        result = runner.invoke(app, ["config", "set", "api_url", "https://new.api.com"])
        
        assert result.exit_code == 0


class TestVersionAndHelp:
    """Tests for version and help."""
    
    def test_version(self):
        """Test version flag."""
        result = runner.invoke(app, ["--version"])
        
        assert result.exit_code == 0
        assert "version" in result.stdout.lower()
    
    def test_help(self):
        """Test help flag."""
        result = runner.invoke(app, ["--help"])
        
        assert result.exit_code == 0
        assert "Usage" in result.stdout


# Fixtures
@pytest.fixture
def mock_config(tmp_path, monkeypatch):
    """Mock configuration."""
    config_path = tmp_path / "config.toml"
    monkeypatch.setenv("MYCLI_CONFIG_PATH", str(config_path))
    return config_path
```

---

## Packaging

### pyproject.toml
```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "mycli"
version = "1.0.0"
description = "My awesome CLI application"
readme = "README.md"
license = "MIT"
requires-python = ">=3.11"
authors = [
    { name = "Your Name", email = "you@example.com" },
]
keywords = ["cli", "command-line"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Environment :: Console",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "typer[all]>=0.9.0",
    "rich>=13.0.0",
    "prompt-toolkit>=3.0.0",
    "pydantic>=2.0.0",
    "pydantic-settings>=2.0.0",
    "tomli-w>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-cov>=4.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
]

[project.scripts]
mycli = "mycli.main:app"

[project.urls]
Homepage = "https://github.com/user/mycli"
Documentation = "https://mycli.readthedocs.io"
Repository = "https://github.com/user/mycli"

[tool.hatch.build.targets.wheel]
packages = ["src/mycli"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --tb=short"

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.mypy]
python_version = "3.11"
strict = true
```

---

## Shell Completion

### Completion Installation
```python
# src/mycli/completion.py
import typer
from pathlib import Path
from enum import Enum


class Shell(str, Enum):
    bash = "bash"
    zsh = "zsh"
    fish = "fish"
    powershell = "powershell"


@app.command()
def completion(
    shell: Shell,
    install: bool = False,
):
    """
    Generate shell completion script.
    
    Use --install to automatically install.
    """
    import subprocess
    
    # Generate completion
    result = subprocess.run(
        ["mycli", "--show-completion", shell.value],
        capture_output=True,
        text=True,
    )
    
    script = result.stdout
    
    if not install:
        print(script)
        return
    
    # Install completion
    if shell == Shell.bash:
        path = Path.home() / ".bash_completion.d" / "mycli"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(script)
        print(f"Installed to {path}")
        print("Add to ~/.bashrc: source ~/.bash_completion.d/mycli")
    
    elif shell == Shell.zsh:
        path = Path.home() / ".zfunc" / "_mycli"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(script)
        print(f"Installed to {path}")
        print("Add to ~/.zshrc: fpath=(~/.zfunc $fpath); autoload -Uz compinit && compinit")
    
    elif shell == Shell.fish:
        path = Path.home() / ".config" / "fish" / "completions" / "mycli.fish"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(script)
        print(f"Installed to {path}")
```

---

## Best Practices Checklist

- [ ] Use Typer for type-hinted CLIs
- [ ] Use Rich for beautiful terminal output
- [ ] Implement --version and --help
- [ ] Support verbose and quiet modes
- [ ] Use environment variables for config
- [ ] Implement shell completion
- [ ] Write comprehensive tests with CliRunner
- [ ] Use proper exit codes
- [ ] Handle keyboard interrupts gracefully
- [ ] Package with pyproject.toml

---

**References:**
- [Typer Documentation](https://typer.tiangolo.com/)
- [Rich Documentation](https://rich.readthedocs.io/)
- [Click Documentation](https://click.palletsprojects.com/)
- [Prompt Toolkit](https://python-prompt-toolkit.readthedocs.io/)
