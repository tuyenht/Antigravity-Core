# Python Data Engineering Expert

> **Version:** 2.0.0 | **Updated:** 2026-01-31
> **Python:** 3.11+ | **Tools:** Dagster, Polars, DuckDB, PySpark
> **Priority:** P1 - Load for data engineering projects

---

You are an expert in Python data engineering, ETL pipelines, and big data processing.

## Key Principles

- Design for scalability and reliability
- Implement idempotent data pipelines
- Monitor data quality continuously
- Use Polars for performance, pandas for compatibility
- Prefer DuckDB for analytics on files
- Use Dagster for modern orchestration

---

## Project Structure

```
data-pipeline/
├── src/
│   ├── __init__.py
│   ├── assets/                 # Dagster assets
│   │   ├── ingestion.py
│   │   ├── transformation.py
│   │   └── serving.py
│   ├── resources/              # External resources
│   │   ├── database.py
│   │   ├── storage.py
│   │   └── kafka.py
│   ├── jobs/                   # Dagster jobs
│   ├── schedules/
│   ├── sensors/
│   ├── ops/                    # Operations
│   ├── io_managers/
│   ├── transformers/
│   │   ├── polars_transforms.py
│   │   └── spark_transforms.py
│   └── quality/
│       └── expectations.py
├── tests/
├── dbt/                        # dbt models
├── data/
│   ├── raw/
│   ├── staging/
│   └── mart/
├── dagster.yaml
└── pyproject.toml
```

---

## Dagster (Modern Orchestration)

### Assets-Based Pipeline
```python
# src/assets/ingestion.py
from dagster import (
    asset,
    AssetExecutionContext,
    MaterializeResult,
    MetadataValue,
    Output,
    DailyPartitionsDefinition,
)
import polars as pl
from datetime import datetime


daily_partitions = DailyPartitionsDefinition(start_date="2024-01-01")


@asset(
    group_name="ingestion",
    description="Raw orders from API",
    partitions_def=daily_partitions,
)
def raw_orders(context: AssetExecutionContext) -> Output[pl.DataFrame]:
    """Ingest raw orders from API."""
    partition_date = context.partition_key
    
    # Fetch from API
    orders = fetch_orders_api(date=partition_date)
    
    df = pl.DataFrame(orders)
    
    context.log.info(f"Ingested {len(df)} orders for {partition_date}")
    
    return Output(
        value=df,
        metadata={
            "row_count": MetadataValue.int(len(df)),
            "partition_date": MetadataValue.text(partition_date),
            "columns": MetadataValue.json(df.columns),
        },
    )


@asset(
    group_name="ingestion",
    description="Raw customers from database",
)
def raw_customers(context: AssetExecutionContext) -> pl.DataFrame:
    """Ingest customers from database."""
    import duckdb
    
    conn = duckdb.connect()
    
    df = conn.execute("""
        SELECT * FROM read_parquet('s3://bucket/customers/*.parquet')
    """).pl()
    
    context.log.info(f"Loaded {len(df)} customers")
    
    return df


# src/assets/transformation.py
@asset(
    group_name="transformation",
    description="Cleaned and validated orders",
    deps=["raw_orders"],
)
def cleaned_orders(
    context: AssetExecutionContext,
    raw_orders: pl.DataFrame,
) -> pl.DataFrame:
    """Clean and validate orders."""
    
    cleaned = (
        raw_orders
        .filter(pl.col("order_id").is_not_null())
        .filter(pl.col("amount") > 0)
        .with_columns([
            pl.col("created_at").str.to_datetime(),
            pl.col("amount").cast(pl.Float64),
        ])
        .unique(subset=["order_id"])
    )
    
    context.log.info(
        f"Cleaned orders: {len(raw_orders)} -> {len(cleaned)}"
    )
    
    return cleaned


@asset(
    group_name="transformation",
    description="Order aggregations by customer",
    deps=["cleaned_orders", "raw_customers"],
)
def customer_orders_summary(
    cleaned_orders: pl.DataFrame,
    raw_customers: pl.DataFrame,
) -> pl.DataFrame:
    """Aggregate orders by customer."""
    
    order_summary = (
        cleaned_orders
        .group_by("customer_id")
        .agg([
            pl.count().alias("total_orders"),
            pl.col("amount").sum().alias("total_amount"),
            pl.col("amount").mean().alias("avg_order_amount"),
            pl.col("created_at").max().alias("last_order_date"),
        ])
    )
    
    return (
        raw_customers
        .join(order_summary, on="customer_id", how="left")
        .with_columns([
            pl.col("total_orders").fill_null(0),
            pl.col("total_amount").fill_null(0.0),
        ])
    )


# src/assets/serving.py
@asset(
    group_name="serving",
    description="Export to data warehouse",
    deps=["customer_orders_summary"],
)
def warehouse_customers(
    context: AssetExecutionContext,
    customer_orders_summary: pl.DataFrame,
) -> MaterializeResult:
    """Export to Snowflake."""
    from snowflake.connector import connect
    
    # Export to Snowflake
    conn = connect(
        user=context.resources.snowflake.user,
        password=context.resources.snowflake.password,
        account=context.resources.snowflake.account,
    )
    
    # Use write_pandas or Arrow
    customer_orders_summary.write_parquet("/tmp/customers.parquet")
    
    # Upload to stage and copy
    # ...
    
    return MaterializeResult(
        metadata={
            "rows_exported": len(customer_orders_summary),
            "destination": "snowflake.analytics.customers",
        }
    )
```

### Jobs and Schedules
```python
# src/jobs/__init__.py
from dagster import define_asset_job, ScheduleDefinition, AssetSelection


# Define job
daily_pipeline_job = define_asset_job(
    name="daily_pipeline",
    selection=AssetSelection.groups("ingestion", "transformation", "serving"),
    description="Daily data pipeline",
)


# Define schedule
daily_schedule = ScheduleDefinition(
    name="daily_pipeline_schedule",
    job=daily_pipeline_job,
    cron_schedule="0 6 * * *",  # 6 AM daily
)


# Sensor for new files
from dagster import sensor, RunRequest


@sensor(job=daily_pipeline_job)
def new_file_sensor(context):
    """Trigger on new S3 files."""
    import boto3
    
    s3 = boto3.client("s3")
    
    response = s3.list_objects_v2(
        Bucket="data-bucket",
        Prefix="incoming/",
    )
    
    for obj in response.get("Contents", []):
        file_key = obj["Key"]
        cursor = context.cursor or ""
        
        if file_key > cursor:
            yield RunRequest(
                run_key=file_key,
                run_config={
                    "ops": {"ingest_file": {"config": {"file_key": file_key}}}
                },
            )
            context.update_cursor(file_key)
```

### Resources
```python
# src/resources/database.py
from dagster import ConfigurableResource
from pydantic import Field
import duckdb


class DuckDBResource(ConfigurableResource):
    """DuckDB database resource."""
    
    database: str = Field(default=":memory:")
    
    def get_connection(self) -> duckdb.DuckDBPyConnection:
        return duckdb.connect(self.database)
    
    def query(self, sql: str) -> pl.DataFrame:
        conn = self.get_connection()
        return conn.execute(sql).pl()


class S3Resource(ConfigurableResource):
    """S3 storage resource."""
    
    bucket: str
    prefix: str = ""
    
    def upload_parquet(self, df: pl.DataFrame, key: str):
        import boto3
        import io
        
        buffer = io.BytesIO()
        df.write_parquet(buffer)
        buffer.seek(0)
        
        s3 = boto3.client("s3")
        s3.upload_fileobj(buffer, self.bucket, f"{self.prefix}/{key}")
    
    def read_parquet(self, key: str) -> pl.DataFrame:
        return pl.read_parquet(f"s3://{self.bucket}/{self.prefix}/{key}")


# Definitions
from dagster import Definitions

defs = Definitions(
    assets=[raw_orders, raw_customers, cleaned_orders, customer_orders_summary],
    jobs=[daily_pipeline_job],
    schedules=[daily_schedule],
    sensors=[new_file_sensor],
    resources={
        "duckdb": DuckDBResource(database="data/analytics.db"),
        "s3": S3Resource(bucket="my-bucket", prefix="data"),
    },
)
```

---

## Polars (High-Performance DataFrames)

### Data Transformation
```python
import polars as pl
from pathlib import Path


class PolarsTransformer:
    """High-performance data transformations with Polars."""
    
    def load_parquet(self, path: str | Path) -> pl.LazyFrame:
        """Load parquet files lazily."""
        return pl.scan_parquet(path)
    
    def load_csv(
        self,
        path: str | Path,
        schema: dict | None = None,
    ) -> pl.LazyFrame:
        """Load CSV files lazily."""
        return pl.scan_csv(
            path,
            schema=schema,
            infer_schema_length=10000,
        )
    
    def transform_orders(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Transform orders data."""
        return (
            lf
            # Filter
            .filter(pl.col("status") != "cancelled")
            .filter(pl.col("amount") > 0)
            
            # Add computed columns
            .with_columns([
                # Parse dates
                pl.col("created_at").str.to_datetime().alias("order_date"),
                
                # Extract components
                pl.col("created_at").str.to_datetime().dt.year().alias("year"),
                pl.col("created_at").str.to_datetime().dt.month().alias("month"),
                
                # Categorize
                pl.when(pl.col("amount") >= 1000)
                .then(pl.lit("high"))
                .when(pl.col("amount") >= 100)
                .then(pl.lit("medium"))
                .otherwise(pl.lit("low"))
                .alias("order_tier"),
            ])
            
            # Deduplicate
            .unique(subset=["order_id"], keep="last")
        )
    
    def aggregate_by_customer(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Aggregate metrics by customer."""
        return (
            lf
            .group_by("customer_id")
            .agg([
                pl.count().alias("order_count"),
                pl.col("amount").sum().alias("total_revenue"),
                pl.col("amount").mean().alias("avg_order_value"),
                pl.col("amount").std().alias("std_order_value"),
                pl.col("order_date").min().alias("first_order"),
                pl.col("order_date").max().alias("last_order"),
                pl.col("product_id").n_unique().alias("unique_products"),
            ])
            .with_columns([
                # Calculate customer lifetime
                (pl.col("last_order") - pl.col("first_order"))
                .dt.total_days()
                .alias("customer_lifetime_days"),
            ])
        )
    
    def window_aggregations(self, lf: pl.LazyFrame) -> pl.LazyFrame:
        """Add window functions."""
        return (
            lf
            .sort("customer_id", "order_date")
            .with_columns([
                # Running totals
                pl.col("amount")
                .cum_sum()
                .over("customer_id")
                .alias("running_total"),
                
                # Lag values
                pl.col("amount")
                .shift(1)
                .over("customer_id")
                .alias("prev_order_amount"),
                
                # Rolling average
                pl.col("amount")
                .rolling_mean(window_size=3)
                .over("customer_id")
                .alias("rolling_avg_3"),
                
                # Rank within group
                pl.col("amount")
                .rank(descending=True)
                .over("customer_id")
                .alias("order_rank"),
            ])
        )
    
    def join_datasets(
        self,
        orders: pl.LazyFrame,
        customers: pl.LazyFrame,
        products: pl.LazyFrame,
    ) -> pl.LazyFrame:
        """Join multiple datasets."""
        return (
            orders
            .join(
                customers.select(["customer_id", "name", "segment"]),
                on="customer_id",
                how="left",
            )
            .join(
                products.select(["product_id", "category", "price"]),
                on="product_id",
                how="left",
            )
        )
    
    def execute(self, lf: pl.LazyFrame) -> pl.DataFrame:
        """Execute lazy query."""
        return lf.collect()
    
    def to_parquet(
        self,
        lf: pl.LazyFrame,
        path: str | Path,
        partition_by: list[str] | None = None,
    ):
        """Write to partitioned parquet."""
        df = lf.collect()
        
        if partition_by:
            df.write_parquet(
                path,
                use_pyarrow=True,
                pyarrow_options={
                    "partition_cols": partition_by,
                },
            )
        else:
            df.write_parquet(path)


# Usage
transformer = PolarsTransformer()

result = (
    transformer.load_parquet("data/orders/*.parquet")
    .pipe(transformer.transform_orders)
    .pipe(transformer.window_aggregations)
    .collect()
)
```

---

## DuckDB (In-Process Analytics)

### SQL Analytics
```python
import duckdb
import polars as pl
from pathlib import Path


class DuckDBAnalytics:
    """DuckDB for SQL analytics on files."""
    
    def __init__(self, database: str = ":memory:"):
        self.conn = duckdb.connect(database)
        self._setup_extensions()
    
    def _setup_extensions(self):
        """Install and load extensions."""
        self.conn.execute("INSTALL httpfs")
        self.conn.execute("LOAD httpfs")
        
        # Configure S3
        self.conn.execute("""
            SET s3_region = 'us-east-1';
        """)
    
    def query(self, sql: str) -> pl.DataFrame:
        """Execute SQL and return Polars DataFrame."""
        return self.conn.execute(sql).pl()
    
    def query_files(self, pattern: str, sql: str) -> pl.DataFrame:
        """Query files with SQL."""
        full_sql = sql.replace("$FILES", f"read_parquet('{pattern}')")
        return self.query(full_sql)
    
    def create_view(self, name: str, source: str):
        """Create view from files."""
        self.conn.execute(f"""
            CREATE OR REPLACE VIEW {name} AS
            SELECT * FROM read_parquet('{source}')
        """)
    
    def aggregate_orders(self, source: str) -> pl.DataFrame:
        """Complex aggregation example."""
        return self.query(f"""
            WITH orders AS (
                SELECT * FROM read_parquet('{source}')
            ),
            
            monthly_stats AS (
                SELECT
                    customer_id,
                    DATE_TRUNC('month', order_date) AS month,
                    COUNT(*) AS order_count,
                    SUM(amount) AS total_amount,
                    AVG(amount) AS avg_amount
                FROM orders
                WHERE status = 'completed'
                GROUP BY customer_id, DATE_TRUNC('month', order_date)
            ),
            
            customer_metrics AS (
                SELECT
                    customer_id,
                    COUNT(DISTINCT month) AS active_months,
                    SUM(order_count) AS lifetime_orders,
                    SUM(total_amount) AS lifetime_value,
                    AVG(total_amount) AS avg_monthly_revenue
                FROM monthly_stats
                GROUP BY customer_id
            )
            
            SELECT
                *,
                CASE
                    WHEN lifetime_value >= 10000 THEN 'platinum'
                    WHEN lifetime_value >= 5000 THEN 'gold'
                    WHEN lifetime_value >= 1000 THEN 'silver'
                    ELSE 'bronze'
                END AS customer_tier,
                PERCENT_RANK() OVER (ORDER BY lifetime_value) AS value_percentile
            FROM customer_metrics
            ORDER BY lifetime_value DESC
        """)
    
    def export_to_parquet(
        self,
        sql: str,
        output_path: str,
        partition_by: list[str] | None = None,
    ):
        """Export query result to partitioned parquet."""
        if partition_by:
            partition_clause = ", ".join(partition_by)
            self.conn.execute(f"""
                COPY ({sql}) TO '{output_path}'
                (FORMAT PARQUET, PARTITION_BY ({partition_clause}))
            """)
        else:
            self.conn.execute(f"""
                COPY ({sql}) TO '{output_path}' (FORMAT PARQUET)
            """)
    
    def close(self):
        self.conn.close()


# Usage
db = DuckDBAnalytics()

# Query S3 directly
result = db.query("""
    SELECT 
        category,
        COUNT(*) as count,
        SUM(amount) as total
    FROM read_parquet('s3://bucket/orders/**/*.parquet')
    WHERE year = 2024
    GROUP BY category
    ORDER BY total DESC
""")

# Join multiple file sources
result = db.query("""
    SELECT 
        o.order_id,
        o.amount,
        c.name as customer_name,
        p.category as product_category
    FROM read_parquet('data/orders/*.parquet') o
    JOIN read_parquet('data/customers/*.parquet') c 
        ON o.customer_id = c.id
    JOIN read_parquet('data/products/*.parquet') p 
        ON o.product_id = p.id
    WHERE o.order_date >= '2024-01-01'
""")
```

---

## PySpark (Big Data)

### Spark Transformations
```python
from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import StructType, StructField, StringType, DoubleType


class SparkPipeline:
    """PySpark data pipeline."""
    
    def __init__(self, app_name: str = "DataPipeline"):
        self.spark = (
            SparkSession.builder
            .appName(app_name)
            .config("spark.sql.adaptive.enabled", "true")
            .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
            .config("spark.sql.shuffle.partitions", "200")
            .getOrCreate()
        )
    
    def read_parquet(self, path: str) -> DataFrame:
        """Read parquet files."""
        return self.spark.read.parquet(path)
    
    def read_delta(self, path: str) -> DataFrame:
        """Read Delta Lake table."""
        return self.spark.read.format("delta").load(path)
    
    def transform_orders(self, df: DataFrame) -> DataFrame:
        """Transform orders with Spark."""
        return (
            df
            # Filter
            .filter(F.col("status") != "cancelled")
            .filter(F.col("amount") > 0)
            
            # Add columns
            .withColumn(
                "order_date",
                F.to_date(F.col("created_at"))
            )
            .withColumn(
                "year",
                F.year(F.col("order_date"))
            )
            .withColumn(
                "month",
                F.month(F.col("order_date"))
            )
            .withColumn(
                "order_tier",
                F.when(F.col("amount") >= 1000, "high")
                .when(F.col("amount") >= 100, "medium")
                .otherwise("low")
            )
            
            # Deduplicate
            .dropDuplicates(["order_id"])
        )
    
    def aggregate_with_window(self, df: DataFrame) -> DataFrame:
        """Add window functions."""
        customer_window = Window.partitionBy("customer_id").orderBy("order_date")
        
        return (
            df
            .withColumn(
                "running_total",
                F.sum("amount").over(customer_window)
            )
            .withColumn(
                "order_rank",
                F.row_number().over(customer_window)
            )
            .withColumn(
                "prev_amount",
                F.lag("amount", 1).over(customer_window)
            )
            .withColumn(
                "rolling_avg",
                F.avg("amount").over(
                    customer_window.rowsBetween(-2, 0)
                )
            )
        )
    
    def write_delta(
        self,
        df: DataFrame,
        path: str,
        mode: str = "overwrite",
        partition_by: list[str] | None = None,
    ):
        """Write to Delta Lake."""
        writer = df.write.format("delta").mode(mode)
        
        if partition_by:
            writer = writer.partitionBy(*partition_by)
        
        writer.save(path)
    
    def optimize_table(self, path: str):
        """Optimize Delta table."""
        from delta.tables import DeltaTable
        
        delta_table = DeltaTable.forPath(self.spark, path)
        delta_table.optimize().executeCompaction()
        delta_table.vacuum(retentionHours=168)  # 7 days
    
    def stop(self):
        self.spark.stop()


# Usage
pipeline = SparkPipeline()

orders = (
    pipeline.read_parquet("s3://bucket/orders/")
    .transform(pipeline.transform_orders)
    .transform(pipeline.aggregate_with_window)
)

pipeline.write_delta(
    orders,
    "s3://bucket/delta/orders",
    partition_by=["year", "month"],
)
```

---

## Great Expectations (Data Quality)

### Data Validation
```python
import great_expectations as gx
from great_expectations.core import ExpectationSuite
from great_expectations.checkpoint import Checkpoint
import polars as pl


class DataQualityValidator:
    """Data quality validation with Great Expectations."""
    
    def __init__(self, context_root: str = "gx"):
        self.context = gx.get_context(context_root_dir=context_root)
    
    def create_orders_suite(self) -> ExpectationSuite:
        """Create expectations for orders data."""
        suite = self.context.add_or_update_expectation_suite(
            expectation_suite_name="orders_suite"
        )
        
        expectations = [
            # Column existence
            gx.expectations.ExpectColumnToExist(column="order_id"),
            gx.expectations.ExpectColumnToExist(column="customer_id"),
            gx.expectations.ExpectColumnToExist(column="amount"),
            
            # Uniqueness
            gx.expectations.ExpectColumnValuesToBeUnique(column="order_id"),
            
            # Not null
            gx.expectations.ExpectColumnValuesToNotBeNull(column="order_id"),
            gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id"),
            
            # Value ranges
            gx.expectations.ExpectColumnValuesToBeBetween(
                column="amount",
                min_value=0,
                max_value=1000000,
            ),
            
            # Value sets
            gx.expectations.ExpectColumnValuesToBeInSet(
                column="status",
                value_set=["pending", "completed", "cancelled", "refunded"],
            ),
            
            # Patterns
            gx.expectations.ExpectColumnValuesToMatchRegex(
                column="email",
                regex=r"^[\w\.-]+@[\w\.-]+\.\w+$",
            ),
            
            # Completeness
            gx.expectations.ExpectColumnValuesToNotBeNull(
                column="amount",
                mostly=0.99,  # 99% must be non-null
            ),
        ]
        
        for exp in expectations:
            suite.add_expectation(exp)
        
        return suite
    
    def validate_dataframe(
        self,
        df: pl.DataFrame,
        suite_name: str,
    ) -> dict:
        """Validate Polars DataFrame."""
        # Convert to pandas for GX
        pandas_df = df.to_pandas()
        
        # Create batch
        batch = self.context.get_batch_list(
            batch_request=gx.BatchRequest(
                datasource_name="pandas",
                data_asset_name="dataframe",
                batch_parameters={"dataframe": pandas_df},
            )
        )[0]
        
        # Validate
        result = batch.validate(expectation_suite_name=suite_name)
        
        return {
            "success": result.success,
            "statistics": result.statistics,
            "results": [
                {
                    "expectation": r.expectation_config.expectation_type,
                    "success": r.success,
                    "observed_value": r.result.get("observed_value"),
                }
                for r in result.results
            ],
        }
    
    def create_checkpoint(
        self,
        name: str,
        suite_name: str,
        data_asset: str,
    ) -> Checkpoint:
        """Create validation checkpoint."""
        return self.context.add_or_update_checkpoint(
            name=name,
            validations=[
                {
                    "expectation_suite_name": suite_name,
                    "batch_request": {
                        "data_asset_name": data_asset,
                    },
                }
            ],
            action_list=[
                {
                    "name": "store_validation_result",
                    "action": {"class_name": "StoreValidationResultAction"},
                },
                {
                    "name": "update_data_docs",
                    "action": {"class_name": "UpdateDataDocsAction"},
                },
            ],
        )


# Usage with Dagster
from dagster import asset, AssetCheckResult, asset_check


@asset_check(asset=cleaned_orders)
def orders_quality_check(
    context,
    cleaned_orders: pl.DataFrame,
) -> AssetCheckResult:
    """Validate orders data quality."""
    validator = DataQualityValidator()
    
    result = validator.validate_dataframe(
        cleaned_orders,
        suite_name="orders_suite",
    )
    
    return AssetCheckResult(
        passed=result["success"],
        metadata={
            "validation_results": result["statistics"],
        },
    )
```

---

## Delta Lake (ACID Data Lake)

### Delta Lake Operations
```python
from delta import DeltaTable
from pyspark.sql import SparkSession


class DeltaLakeManager:
    """Delta Lake management."""
    
    def __init__(self, spark: SparkSession):
        self.spark = spark
    
    def upsert(
        self,
        source_df,
        target_path: str,
        merge_keys: list[str],
        update_columns: list[str] | None = None,
    ):
        """Upsert (merge) data into Delta table."""
        delta_table = DeltaTable.forPath(self.spark, target_path)
        
        # Build merge condition
        merge_condition = " AND ".join([
            f"target.{key} = source.{key}"
            for key in merge_keys
        ])
        
        merge_builder = (
            delta_table.alias("target")
            .merge(source_df.alias("source"), merge_condition)
        )
        
        # When matched, update
        if update_columns:
            update_set = {col: f"source.{col}" for col in update_columns}
        else:
            update_set = {
                col: f"source.{col}"
                for col in source_df.columns
                if col not in merge_keys
            }
        
        merge_builder = merge_builder.whenMatchedUpdate(set=update_set)
        
        # When not matched, insert
        merge_builder = merge_builder.whenNotMatchedInsertAll()
        
        merge_builder.execute()
    
    def time_travel(self, path: str, version: int = None, timestamp: str = None):
        """Read historical version."""
        reader = self.spark.read.format("delta")
        
        if version is not None:
            reader = reader.option("versionAsOf", version)
        elif timestamp:
            reader = reader.option("timestampAsOf", timestamp)
        
        return reader.load(path)
    
    def get_history(self, path: str, limit: int = 10):
        """Get table history."""
        delta_table = DeltaTable.forPath(self.spark, path)
        return delta_table.history(limit)
    
    def optimize(self, path: str, z_order_columns: list[str] | None = None):
        """Optimize Delta table."""
        delta_table = DeltaTable.forPath(self.spark, path)
        
        optimize_builder = delta_table.optimize()
        
        if z_order_columns:
            optimize_builder.executeZOrderBy(z_order_columns)
        else:
            optimize_builder.executeCompaction()
    
    def vacuum(self, path: str, retention_hours: int = 168):
        """Clean up old files."""
        delta_table = DeltaTable.forPath(self.spark, path)
        delta_table.vacuum(retentionHours=retention_hours)
    
    def create_scd_type2(
        self,
        source_df,
        target_path: str,
        key_columns: list[str],
        compare_columns: list[str],
    ):
        """Slowly Changing Dimension Type 2."""
        from pyspark.sql import functions as F
        
        delta_table = DeltaTable.forPath(self.spark, target_path)
        
        # Find changed records
        target_df = self.spark.read.format("delta").load(target_path)
        current_df = target_df.filter(F.col("is_current") == True)
        
        # Join and find changes
        join_condition = [
            source_df[col] == current_df[col]
            for col in key_columns
        ]
        
        changes = (
            source_df.alias("source")
            .join(current_df.alias("target"), join_condition, "left")
            .filter(
                # New records
                F.col(f"target.{key_columns[0]}").isNull() |
                # Changed records
                F.expr(" OR ".join([
                    f"source.{col} != target.{col}"
                    for col in compare_columns
                ]))
            )
        )
        
        # Close old records
        merge_condition = " AND ".join([
            f"target.{col} = staged.{col}"
            for col in key_columns
        ])
        
        (
            delta_table.alias("target")
            .merge(changes.alias("staged"), merge_condition)
            .whenMatchedUpdate(set={
                "is_current": "false",
                "end_date": "current_timestamp()",
            })
            .execute()
        )
        
        # Insert new records
        new_records = changes.withColumn("is_current", F.lit(True))
        new_records.write.format("delta").mode("append").save(target_path)


# Usage
delta_manager = DeltaLakeManager(spark)

# Upsert data
delta_manager.upsert(
    source_df=new_orders,
    target_path="s3://bucket/delta/orders",
    merge_keys=["order_id"],
    update_columns=["status", "amount", "updated_at"],
)

# Time travel
yesterday_data = delta_manager.time_travel(
    "s3://bucket/delta/orders",
    timestamp="2024-01-14",
)
```

---

## Kafka Streaming

### Kafka Consumer/Producer
```python
from confluent_kafka import Consumer, Producer, KafkaError
from pydantic import BaseModel
import json
from typing import Callable, Iterator
import polars as pl


class KafkaEvent(BaseModel):
    """Base Kafka event."""
    event_type: str
    timestamp: str
    payload: dict


class KafkaStreamProcessor:
    """Kafka stream processing."""
    
    def __init__(
        self,
        bootstrap_servers: str,
        group_id: str,
    ):
        self.consumer_config = {
            "bootstrap.servers": bootstrap_servers,
            "group.id": group_id,
            "auto.offset.reset": "earliest",
            "enable.auto.commit": False,
        }
        
        self.producer_config = {
            "bootstrap.servers": bootstrap_servers,
            "acks": "all",
        }
    
    def consume(
        self,
        topics: list[str],
        batch_size: int = 100,
        timeout: float = 1.0,
    ) -> Iterator[list[KafkaEvent]]:
        """Consume messages in batches."""
        consumer = Consumer(self.consumer_config)
        consumer.subscribe(topics)
        
        try:
            batch = []
            
            while True:
                msg = consumer.poll(timeout=timeout)
                
                if msg is None:
                    if batch:
                        yield batch
                        batch = []
                    continue
                
                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        continue
                    raise Exception(msg.error())
                
                event = KafkaEvent(**json.loads(msg.value()))
                batch.append(event)
                
                if len(batch) >= batch_size:
                    yield batch
                    consumer.commit(asynchronous=False)
                    batch = []
                    
        finally:
            consumer.close()
    
    def produce(self, topic: str, event: KafkaEvent):
        """Produce single message."""
        producer = Producer(self.producer_config)
        
        producer.produce(
            topic=topic,
            value=event.model_dump_json().encode(),
            key=event.event_type.encode(),
        )
        producer.flush()
    
    def process_stream(
        self,
        source_topics: list[str],
        sink_topic: str,
        transform_fn: Callable[[list[KafkaEvent]], list[KafkaEvent]],
    ):
        """Process stream with transformation."""
        producer = Producer(self.producer_config)
        
        for batch in self.consume(source_topics):
            transformed = transform_fn(batch)
            
            for event in transformed:
                producer.produce(
                    topic=sink_topic,
                    value=event.model_dump_json().encode(),
                )
            
            producer.flush()


# Dagster sensor for Kafka
from dagster import sensor, RunRequest


@sensor(job=process_events_job)
def kafka_sensor(context):
    """Trigger on Kafka messages."""
    processor = KafkaStreamProcessor(
        bootstrap_servers="localhost:9092",
        group_id="dagster-sensor",
    )
    
    for batch in processor.consume(["events"], batch_size=1000, timeout=5.0):
        if batch:
            yield RunRequest(
                run_key=f"kafka-{batch[0].timestamp}",
                run_config={
                    "ops": {
                        "process_events": {
                            "config": {
                                "events": [e.model_dump() for e in batch]
                            }
                        }
                    }
                },
            )
            break  # Process one batch per sensor tick
```

---

## Best Practices Checklist

- [ ] Use Dagster for modern orchestration
- [ ] Use Polars for DataFrame operations (10x faster)
- [ ] Use DuckDB for SQL analytics on files
- [ ] Implement data quality with Great Expectations
- [ ] Use Delta Lake for ACID transactions
- [ ] Partition data by date/time
- [ ] Use columnar formats (Parquet)
- [ ] Implement incremental processing
- [ ] Monitor pipeline execution
- [ ] Version control all pipeline code

---

**References:**
- [Dagster Documentation](https://docs.dagster.io/)
- [Polars User Guide](https://pola-rs.github.io/polars/)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [Great Expectations](https://docs.greatexpectations.io/)
- [Delta Lake](https://delta.io/)
