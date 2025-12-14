# Data Engineering Tools

Modern data platform tools - Apache projects for cloud-native data engineering.

---

## Apache Spark

### Option 1: Local Master (Simple, for learning)

```bash
cd ~/code/apps/my-project
uv venv --python 3.11.9
source .venv/bin/activate
uv pip install pyspark pandas
```

**Usage:**

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("local[*]") \
    .appName("MyApp") \
    .getOrCreate()

df = spark.read.parquet("data.parquet")
df.show()
spark.stop()
```

Or command line:
```bash
pyspark --master local[*]
```

### Option 2: Podman Container (Production-like)

```bash
# Start Spark cluster
podman run -d \
  --name spark-master \
  -p 8080:8080 \
  -p 7077:7077 \
  -e SPARK_MODE=master \
  bitnami/spark:3.5.0

# Spark UI: http://localhost:8080
```

**Connect from PySpark:**

```python
spark = SparkSession.builder \
    .master("spark://localhost:7077") \
    .appName("MyApp") \
    .getOrCreate()
```

### Which to Use?

| Mode | Use When |
|------|----------|
| **Local** | Learning Spark, quick scripts, single-machine processing |
| **Podman** | Testing cluster behavior, realistic setups, multi-worker simulation |

**Status:** ✅ Completed

---

## Apache Kafka

Event streaming platform for real-time data pipelines.

### Installation (Podman)

```bash
# Coming soon - Kafka + Zookeeper setup
```

**Status:** 📝 Planned

---

## Apache Airflow

Workflow orchestration for data pipelines.

### Installation

```bash
# Coming soon - Airflow with LocalExecutor/KubernetesExecutor
```

**Use Cases:**
- Schedule Spark jobs
- Coordinate ETL workflows  
- Data quality checks
- dbt orchestration

**Status:** 📝 Planned

---

## Apache Iceberg

Open table format for huge analytic datasets.

### Why Iceberg?

- ACID transactions on data lakes
- Time travel and versioning
- Schema evolution
- Works with Spark, Trino, Flink

### Installation

```bash
# PySpark with Iceberg
uv pip install 'pyspark[iceberg]'
```

**Example:**

```python
spark = SparkSession.builder \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
    .getOrCreate()

# Create Iceberg table
spark.sql("""
    CREATE TABLE my_catalog.db.table (
        id bigint,
        data string,
        category string
    ) USING iceberg
    PARTITIONED BY (category)
""")
```

**Status:** 📝 Planned

---

## dbt (data build tool)

SQL-based transformation framework for analytics.

### Installation

```bash
uv pip install dbt-core dbt-bigquery dbt-postgres
```

### Basic Usage

```bash
# Initialize project
dbt init my_project

# Run transformations
dbt run

# Test data quality
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

### Typical Workflow

1. Write SQL models in `models/`
2. Define tests in YAML
3. Run `dbt run` to execute transformations
4. Run `dbt test` for data quality checks

### Works With

- BigQuery (GCP)
- PostgreSQL (local dev)
- Spark (via dbt-spark adapter)

**Resources:**
- [Official dbt Docs](https://docs.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

**Status:** 📝 Planned

---

## Trino

Distributed SQL query engine for big data.

### Why Trino?

- Query data across multiple sources (BigQuery, S3, PostgreSQL)
- Fast analytics on large datasets
- SQL interface to everything

### Installation (Podman)

```bash
# Coming soon - Trino server setup
```

**Use Cases:**
- Query Iceberg tables
- Federated queries across data sources
- Interactive analytics

**Status:** 📝 Planned

---

## DuckDB (Optional)

**What it is:** In-process analytical database for fast local analytics.

**Do you need it?** No, but it's useful for:
- Quick data exploration without starting Spark
- Testing queries on small datasets (< 10GB)
- Direct Parquet/CSV analysis
- Local development before moving to Spark/Trino

### Installation

```bash
uv pip install duckdb
```

### Usage

```python
import duckdb

# Query Parquet directly (no Spark needed)
result = duckdb.query("SELECT * FROM 'data.parquet' WHERE value > 100")
df = result.df()  # Convert to pandas

# Query multiple files
duckdb.query("SELECT * FROM 'data/*.parquet'").show()
```

### When to Use

| Tool | Use Case |
|------|----------|
| **DuckDB** | Quick local analysis, < 10GB data, testing queries |
| **Spark** | Distributed processing, > 10GB data, production pipelines |
| **Trino** | Query multiple data sources, interactive analytics |

**Status:** Optional - Install if you want fast local analytics

---

## Data Pipeline Architecture

**Typical Flow:**

```
Source Data
    ↓
Apache Kafka (streaming)
    ↓
Apache Spark (processing)
    ↓
Apache Iceberg (storage)
    ↓
dbt (transformation)
    ↓
Trino (analytics)
    ↓
Visualization / ML
```

**Orchestrated by:** Apache Airflow

---

## Project Template: Data Pipeline

```
data-pipeline/
├── spark/
│   ├── jobs/
│   │   ├── ingest.py
│   │   └── transform.py
│   └── requirements.txt
├── dbt/
│   ├── models/
│   └── dbt_project.yml
├── airflow/
│   └── dags/
│       └── daily_pipeline.py
├── docker-compose.yml
└── README.md
```

---

## Next Steps

- [Cloud & GCP Setup](13-cloud-gcp.md)
- [Kubernetes](07-kubernetes.md)
- [Databases](12-databases.md)

---

**Current Status:**
- ✅ Spark configured (local + Podman)
- 📝 Kafka, Airflow, Iceberg, dbt, Trino - planned installations


