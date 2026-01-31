# Python Data Science Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Polars:** 0.20+ | **Pandas:** 2.x
> **Priority:** P1 - Load for data science projects

---

You are an expert in Python data science and analytics.

## Key Principles

- Write reproducible analysis code
- Use modern tools (Polars, DuckDB)
- Document analysis steps clearly
- Validate data quality
- Follow data science best practices
- Use type hints for data schemas

---

## Project Structure

```
project/
├── data/
│   ├── raw/                # Original data (immutable)
│   ├── interim/            # Intermediate data
│   ├── processed/          # Final processed data
│   └── external/           # External data sources
├── notebooks/
│   ├── 01_exploration.ipynb
│   ├── 02_cleaning.ipynb
│   ├── 03_feature_engineering.ipynb
│   └── 04_modeling.ipynb
├── src/
│   ├── __init__.py
│   ├── config.py
│   ├── data/
│   │   ├── loaders.py
│   │   ├── cleaners.py
│   │   └── validators.py
│   ├── features/
│   │   └── engineering.py
│   ├── models/
│   │   ├── train.py
│   │   └── evaluate.py
│   └── visualization/
│       └── plots.py
├── tests/
├── models/                 # Saved models
├── reports/
│   └── figures/
├── pyproject.toml
└── README.md
```

---

## Polars (Modern DataFrame Library)

### Basic Operations
```python
import polars as pl

# Read data
df = pl.read_csv("data/raw/data.csv")
df = pl.read_parquet("data/raw/data.parquet")

# Display info
print(df.schema)
print(df.describe())

# Select and filter
result = df.select([
    "column1",
    "column2",
    pl.col("column3").alias("renamed"),
])

result = df.filter(
    (pl.col("age") > 18) & 
    (pl.col("status") == "active")
)

# Group by and aggregate
summary = df.group_by("category").agg([
    pl.col("value").sum().alias("total"),
    pl.col("value").mean().alias("average"),
    pl.col("value").count().alias("count"),
    pl.col("value").std().alias("std_dev"),
])

# Window functions
df = df.with_columns([
    pl.col("value").rolling_mean(window_size=7).alias("rolling_avg"),
    pl.col("value").rank().over("category").alias("rank_in_category"),
])

# Lazy evaluation (for large datasets)
lazy_df = pl.scan_parquet("data/large/*.parquet")
result = (
    lazy_df
    .filter(pl.col("date") > "2024-01-01")
    .group_by("category")
    .agg(pl.col("value").sum())
    .collect()
)
```

### Data Cleaning with Polars
```python
def clean_dataframe(df: pl.DataFrame) -> pl.DataFrame:
    """Clean and preprocess dataframe."""
    return (
        df
        # Remove duplicates
        .unique()
        
        # Handle missing values
        .with_columns([
            pl.col("numeric_col").fill_null(pl.col("numeric_col").median()),
            pl.col("string_col").fill_null("unknown"),
        ])
        
        # Type conversions
        .with_columns([
            pl.col("date_str").str.to_datetime("%Y-%m-%d").alias("date"),
            pl.col("category").cast(pl.Categorical),
        ])
        
        # Remove outliers (IQR method)
        .filter(
            pl.col("value").is_between(
                pl.col("value").quantile(0.01),
                pl.col("value").quantile(0.99),
            )
        )
        
        # Create new columns
        .with_columns([
            (pl.col("value") / pl.col("total")).alias("ratio"),
            pl.col("text").str.to_lowercase().alias("text_clean"),
        ])
    )
```

---

## Pandas 2.x (with PyArrow Backend)

### Modern Pandas
```python
import pandas as pd

# Use PyArrow backend for better performance
df = pd.read_csv(
    "data/raw/data.csv",
    dtype_backend="pyarrow",
    engine="pyarrow",
)

# Or convert existing dataframe
df = df.convert_dtypes(dtype_backend="pyarrow")

# Type hints with pandas
from pandas import DataFrame, Series

def process_data(df: DataFrame) -> DataFrame:
    """Process dataframe with type hints."""
    return df.assign(
        new_col=lambda x: x["col1"] * 2,
        category=lambda x: pd.Categorical(x["category"]),
    )

# Method chaining
result = (
    df
    .query("age > 18 and status == 'active'")
    .assign(
        age_group=lambda x: pd.cut(x["age"], bins=[0, 18, 35, 50, 100]),
        log_value=lambda x: np.log1p(x["value"]),
    )
    .groupby("category", as_index=False)
    .agg(
        total=("value", "sum"),
        average=("value", "mean"),
        count=("value", "count"),
    )
    .sort_values("total", ascending=False)
)
```

---

## DuckDB (In-Process Analytics)

### SQL Analytics in Python
```python
import duckdb

# Query from files directly (no loading into memory)
result = duckdb.sql("""
    SELECT 
        category,
        COUNT(*) as count,
        AVG(value) as avg_value,
        SUM(value) as total
    FROM 'data/raw/*.parquet'
    WHERE date >= '2024-01-01'
    GROUP BY category
    ORDER BY total DESC
""").df()

# Query pandas/polars dataframes
df = pd.read_csv("data/raw/data.csv")

result = duckdb.sql("""
    SELECT 
        category,
        percentile_cont(0.5) WITHIN GROUP (ORDER BY value) as median
    FROM df
    GROUP BY category
""").df()

# Window functions
result = duckdb.sql("""
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY value DESC) as rank,
        LAG(value) OVER (PARTITION BY category ORDER BY date) as prev_value,
        value - LAG(value) OVER (PARTITION BY category ORDER BY date) as change
    FROM df
""").df()

# Export to various formats
duckdb.sql("SELECT * FROM df WHERE value > 100").write_parquet("output.parquet")
duckdb.sql("SELECT * FROM df WHERE value > 100").write_csv("output.csv")
```

---

## Data Validation

### Pandera (DataFrame Validation)
```python
import pandera as pa
from pandera.typing import DataFrame, Series


# Define schema with type hints
class UserSchema(pa.DataFrameModel):
    """Schema for user data."""
    
    user_id: Series[int] = pa.Field(ge=1, unique=True)
    email: Series[str] = pa.Field(str_matches=r"^[\w.-]+@[\w.-]+\.\w+$")
    age: Series[int] = pa.Field(ge=0, le=120)
    balance: Series[float] = pa.Field(ge=0)
    status: Series[str] = pa.Field(isin=["active", "inactive", "pending"])
    created_at: Series[pa.DateTime]
    
    class Config:
        strict = True
        coerce = True


# Validate dataframe
@pa.check_types
def process_users(df: DataFrame[UserSchema]) -> DataFrame[UserSchema]:
    """Process user data with validation."""
    return df.assign(
        balance=lambda x: x["balance"] * 1.1
    )


# Usage
try:
    validated_df = UserSchema.validate(raw_df)
    result = process_users(validated_df)
except pa.errors.SchemaError as e:
    print(f"Validation failed: {e}")
```

### Great Expectations
```python
import great_expectations as gx

# Create context
context = gx.get_context()

# Define expectations
validator = context.sources.pandas_default.read_csv("data/raw/data.csv")

validator.expect_column_values_to_not_be_null("user_id")
validator.expect_column_values_to_be_unique("user_id")
validator.expect_column_values_to_be_between("age", 0, 120)
validator.expect_column_values_to_be_in_set("status", ["active", "inactive"])
validator.expect_column_values_to_match_regex("email", r"^[\w.-]+@[\w.-]+\.\w+$")

# Run validation
results = validator.validate()

if not results.success:
    print("Data validation failed!")
    for result in results.results:
        if not result.success:
            print(f"  - {result.expectation_config.expectation_type}: FAILED")
```

---

## Visualization

### Plotly Express (Interactive)
```python
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Scatter plot
fig = px.scatter(
    df,
    x="value_x",
    y="value_y",
    color="category",
    size="size_col",
    hover_data=["name", "details"],
    title="Scatter Plot with Categories",
)
fig.show()

# Distribution
fig = px.histogram(
    df,
    x="value",
    color="category",
    marginal="box",
    title="Distribution by Category",
)
fig.show()

# Time series
fig = px.line(
    df,
    x="date",
    y="value",
    color="category",
    title="Time Series by Category",
)
fig.update_xaxes(rangeslider_visible=True)
fig.show()

# Faceted plots
fig = px.scatter(
    df,
    x="x",
    y="y",
    color="category",
    facet_col="segment",
    facet_row="region",
    title="Faceted Scatter Plot",
)
fig.show()

# Subplots
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=("Distribution", "Trend", "Comparison", "Breakdown")
)

fig.add_trace(
    go.Histogram(x=df["value"], name="Distribution"),
    row=1, col=1
)
fig.add_trace(
    go.Scatter(x=df["date"], y=df["value"], name="Trend", mode="lines"),
    row=1, col=2
)
fig.add_trace(
    go.Bar(x=df["category"], y=df["count"], name="Comparison"),
    row=2, col=1
)
fig.add_trace(
    go.Pie(labels=df["category"], values=df["value"], name="Breakdown"),
    row=2, col=2
)

fig.update_layout(height=800, title_text="Dashboard")
fig.show()
```

### Altair (Declarative)
```python
import altair as alt

# Enable for large datasets
alt.data_transformers.enable("vegafusion")

# Scatter with regression
chart = (
    alt.Chart(df)
    .mark_point()
    .encode(
        x="x:Q",
        y="y:Q",
        color="category:N",
        tooltip=["name", "x", "y", "category"],
    )
    .properties(width=600, height=400, title="Scatter Plot")
    .interactive()
)

# Add regression line
regression = chart.transform_regression("x", "y").mark_line()
(chart + regression).display()

# Faceted bar chart
chart = (
    alt.Chart(df)
    .mark_bar()
    .encode(
        x="category:N",
        y="sum(value):Q",
        color="segment:N",
        column="region:N",
    )
    .properties(width=200)
)
chart.display()

# Interactive selection
brush = alt.selection_interval()

points = (
    alt.Chart(df)
    .mark_point()
    .encode(
        x="x:Q",
        y="y:Q",
        color=alt.condition(brush, "category:N", alt.value("lightgray")),
    )
    .add_params(brush)
)

bars = (
    alt.Chart(df)
    .mark_bar()
    .encode(
        y="category:N",
        x="count()",
        color="category:N",
    )
    .transform_filter(brush)
)

(points | bars).display()
```

### Seaborn (Statistical)
```python
import seaborn as sns
import matplotlib.pyplot as plt

# Set style
sns.set_theme(style="whitegrid", palette="deep")

# Figure with subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Distribution plot
sns.histplot(data=df, x="value", hue="category", kde=True, ax=axes[0, 0])
axes[0, 0].set_title("Distribution by Category")

# Box plot
sns.boxplot(data=df, x="category", y="value", ax=axes[0, 1])
axes[0, 1].set_title("Value by Category")

# Scatter with regression
sns.regplot(data=df, x="x", y="y", ax=axes[1, 0])
axes[1, 0].set_title("Regression Plot")

# Heatmap
correlation = df.select_dtypes("number").corr()
sns.heatmap(correlation, annot=True, cmap="coolwarm", ax=axes[1, 1])
axes[1, 1].set_title("Correlation Heatmap")

plt.tight_layout()
plt.savefig("reports/figures/analysis.png", dpi=300)
plt.show()
```

---

## Statistical Analysis

### Hypothesis Testing
```python
from scipy import stats
import numpy as np

def perform_statistical_tests(group_a: np.ndarray, group_b: np.ndarray) -> dict:
    """Perform comprehensive statistical tests."""
    results = {}
    
    # Normality tests
    _, p_normality_a = stats.shapiro(group_a[:5000])  # Shapiro limited to 5000
    _, p_normality_b = stats.shapiro(group_b[:5000])
    
    is_normal = p_normality_a > 0.05 and p_normality_b > 0.05
    results["normality"] = {
        "group_a_p": p_normality_a,
        "group_b_p": p_normality_b,
        "is_normal": is_normal,
    }
    
    # Variance test
    _, p_variance = stats.levene(group_a, group_b)
    equal_variance = p_variance > 0.05
    results["variance"] = {
        "p_value": p_variance,
        "equal_variance": equal_variance,
    }
    
    # Choose appropriate test
    if is_normal:
        # Parametric: t-test
        stat, p_value = stats.ttest_ind(
            group_a, group_b,
            equal_var=equal_variance
        )
        test_name = "t-test" if equal_variance else "Welch's t-test"
    else:
        # Non-parametric: Mann-Whitney U
        stat, p_value = stats.mannwhitneyu(group_a, group_b, alternative="two-sided")
        test_name = "Mann-Whitney U"
    
    results["test"] = {
        "name": test_name,
        "statistic": stat,
        "p_value": p_value,
        "significant": p_value < 0.05,
    }
    
    # Effect size (Cohen's d)
    pooled_std = np.sqrt(
        ((len(group_a) - 1) * group_a.std()**2 + 
         (len(group_b) - 1) * group_b.std()**2) /
        (len(group_a) + len(group_b) - 2)
    )
    cohens_d = (group_a.mean() - group_b.mean()) / pooled_std
    
    results["effect_size"] = {
        "cohens_d": cohens_d,
        "interpretation": interpret_cohens_d(cohens_d),
    }
    
    # Confidence interval for difference
    diff_mean = group_a.mean() - group_b.mean()
    se = np.sqrt(group_a.var()/len(group_a) + group_b.var()/len(group_b))
    ci = stats.t.interval(0.95, df=len(group_a)+len(group_b)-2, loc=diff_mean, scale=se)
    
    results["confidence_interval"] = {
        "difference": diff_mean,
        "ci_95": ci,
    }
    
    return results


def interpret_cohens_d(d: float) -> str:
    """Interpret Cohen's d effect size."""
    d = abs(d)
    if d < 0.2:
        return "negligible"
    elif d < 0.5:
        return "small"
    elif d < 0.8:
        return "medium"
    else:
        return "large"
```

---

## Feature Engineering

### Feature Engineering Pipeline
```python
import polars as pl
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline


class FeatureEngineer:
    """Feature engineering pipeline."""
    
    def __init__(self, df: pl.DataFrame):
        self.df = df
        self.encoders = {}
        self.scalers = {}
    
    def create_datetime_features(self, col: str) -> "FeatureEngineer":
        """Extract datetime features."""
        self.df = self.df.with_columns([
            pl.col(col).dt.year().alias(f"{col}_year"),
            pl.col(col).dt.month().alias(f"{col}_month"),
            pl.col(col).dt.day().alias(f"{col}_day"),
            pl.col(col).dt.weekday().alias(f"{col}_weekday"),
            pl.col(col).dt.hour().alias(f"{col}_hour"),
            (pl.col(col).dt.weekday() >= 5).alias(f"{col}_is_weekend"),
            pl.col(col).dt.quarter().alias(f"{col}_quarter"),
        ])
        return self
    
    def create_lag_features(
        self,
        col: str,
        lags: list[int],
        group_by: str | None = None,
    ) -> "FeatureEngineer":
        """Create lag features."""
        for lag in lags:
            if group_by:
                self.df = self.df.with_columns([
                    pl.col(col).shift(lag).over(group_by).alias(f"{col}_lag_{lag}")
                ])
            else:
                self.df = self.df.with_columns([
                    pl.col(col).shift(lag).alias(f"{col}_lag_{lag}")
                ])
        return self
    
    def create_rolling_features(
        self,
        col: str,
        windows: list[int],
        functions: list[str] = ["mean", "std", "min", "max"],
    ) -> "FeatureEngineer":
        """Create rolling window features."""
        for window in windows:
            for func in functions:
                if func == "mean":
                    expr = pl.col(col).rolling_mean(window)
                elif func == "std":
                    expr = pl.col(col).rolling_std(window)
                elif func == "min":
                    expr = pl.col(col).rolling_min(window)
                elif func == "max":
                    expr = pl.col(col).rolling_max(window)
                else:
                    continue
                
                self.df = self.df.with_columns([
                    expr.alias(f"{col}_rolling_{func}_{window}")
                ])
        return self
    
    def create_interaction_features(
        self,
        col1: str,
        col2: str,
    ) -> "FeatureEngineer":
        """Create interaction features."""
        self.df = self.df.with_columns([
            (pl.col(col1) * pl.col(col2)).alias(f"{col1}_x_{col2}"),
            (pl.col(col1) / (pl.col(col2) + 1e-8)).alias(f"{col1}_div_{col2}"),
            (pl.col(col1) + pl.col(col2)).alias(f"{col1}_plus_{col2}"),
        ])
        return self
    
    def encode_categorical(
        self,
        col: str,
        method: str = "label",
    ) -> "FeatureEngineer":
        """Encode categorical features."""
        if method == "label":
            # Get unique values and create mapping
            unique_vals = self.df[col].unique().to_list()
            mapping = {v: i for i, v in enumerate(unique_vals)}
            
            self.df = self.df.with_columns([
                pl.col(col).replace(mapping).alias(f"{col}_encoded")
            ])
            self.encoders[col] = mapping
        
        elif method == "onehot":
            # One-hot encoding
            self.df = self.df.to_dummies(columns=[col])
        
        return self
    
    def scale_numeric(
        self,
        cols: list[str],
        method: str = "standard",
    ) -> "FeatureEngineer":
        """Scale numeric features."""
        for col in cols:
            if method == "standard":
                mean = self.df[col].mean()
                std = self.df[col].std()
                self.df = self.df.with_columns([
                    ((pl.col(col) - mean) / std).alias(f"{col}_scaled")
                ])
                self.scalers[col] = {"mean": mean, "std": std}
            
            elif method == "minmax":
                min_val = self.df[col].min()
                max_val = self.df[col].max()
                self.df = self.df.with_columns([
                    ((pl.col(col) - min_val) / (max_val - min_val)).alias(f"{col}_scaled")
                ])
                self.scalers[col] = {"min": min_val, "max": max_val}
        
        return self
    
    def get_dataframe(self) -> pl.DataFrame:
        """Return processed dataframe."""
        return self.df


# Usage
engineer = FeatureEngineer(df)
processed_df = (
    engineer
    .create_datetime_features("timestamp")
    .create_lag_features("value", lags=[1, 7, 30], group_by="category")
    .create_rolling_features("value", windows=[7, 14, 30])
    .encode_categorical("category", method="label")
    .scale_numeric(["value", "amount"], method="standard")
    .get_dataframe()
)
```

---

## Experiment Tracking (MLflow)

```python
import mlflow
from mlflow.models import infer_signature
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

# Set tracking URI
mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("classification-experiment")

# Start run
with mlflow.start_run(run_name="random_forest_v1"):
    # Log parameters
    params = {
        "n_estimators": 100,
        "max_depth": 10,
        "min_samples_split": 5,
        "random_state": 42,
    }
    mlflow.log_params(params)
    
    # Train model
    model = RandomForestClassifier(**params)
    model.fit(X_train, y_train)
    
    # Evaluate
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)
    cv_scores = cross_val_score(model, X_train, y_train, cv=5)
    
    # Log metrics
    mlflow.log_metrics({
        "train_accuracy": train_score,
        "test_accuracy": test_score,
        "cv_mean": cv_scores.mean(),
        "cv_std": cv_scores.std(),
    })
    
    # Log model
    signature = infer_signature(X_train, model.predict(X_train))
    mlflow.sklearn.log_model(
        model,
        "model",
        signature=signature,
        registered_model_name="random_forest_classifier",
    )
    
    # Log artifacts
    mlflow.log_artifact("reports/figures/feature_importance.png")
    
    print(f"Run ID: {mlflow.active_run().info.run_id}")
```

---

## Reproducibility

### Configuration
```python
# src/config.py
from pathlib import Path
from pydantic_settings import BaseSettings


class Config(BaseSettings):
    """Project configuration."""
    
    # Paths
    data_dir: Path = Path("data")
    models_dir: Path = Path("models")
    reports_dir: Path = Path("reports")
    
    # Reproducibility
    random_seed: int = 42
    
    # Data
    train_size: float = 0.8
    val_size: float = 0.1
    test_size: float = 0.1
    
    # Model
    model_name: str = "random_forest"
    
    class Config:
        env_file = ".env"


config = Config()


# Set seeds everywhere
def set_seeds(seed: int = 42) -> None:
    """Set random seeds for reproducibility."""
    import random
    import numpy as np
    
    random.seed(seed)
    np.random.seed(seed)
    
    try:
        import torch
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
    except ImportError:
        pass
```

---

## Best Practices Checklist

- [ ] Use Polars for fast DataFrame operations
- [ ] Use DuckDB for SQL analytics on files
- [ ] Validate data with Pandera/Great Expectations
- [ ] Use Plotly/Altair for interactive visualizations
- [ ] Track experiments with MLflow
- [ ] Set random seeds for reproducibility
- [ ] Use type hints with DataFrames
- [ ] Document analysis in notebooks
- [ ] Version control data and models
- [ ] Use configuration files for parameters

---

**References:**
- [Polars Documentation](https://pola-rs.github.io/polars-book/)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [Pandera Documentation](https://pandera.readthedocs.io/)
- [MLflow Documentation](https://mlflow.org/docs/latest/)
