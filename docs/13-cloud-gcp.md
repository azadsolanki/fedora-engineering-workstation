# Cloud & Google Cloud Platform Setup

Google Cloud Platform tools and configuration.

---

## Google Cloud SDK

### Installation

```bash
# Install from Fedora repos
sudo dnf install -y google-cloud-cli

# Or manual installation for latest version:
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### Initialize gcloud

```bash
# Authenticate
gcloud init

# Login
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud config list
```

### Components

```bash
# Install additional components
gcloud components install kubectl
gcloud components install bq
gcloud components install gsutil

# Update
gcloud components update
```

---

## BigQuery CLI

### Setup

```bash
# Authenticate for BigQuery
gcloud auth application-default login
```

### Common Commands

```bash
# List datasets
bq ls

# Query
bq query --use_legacy_sql=false \
  'SELECT * FROM `project.dataset.table` LIMIT 10'

# Load data
bq load \
  --source_format=PARQUET \
  dataset.table \
  gs://bucket/data/*.parquet

# Export data
bq extract \
  dataset.table \
  gs://bucket/export/*.parquet
```

### Python Client

```bash
uv pip install google-cloud-bigquery pandas-gbq
```

```python
from google.cloud import bigquery

client = bigquery.Client()

query = """
    SELECT name, COUNT(*) as count
    FROM `bigquery-public-data.usa_names.usa_1910_current`
    WHERE state = 'CA'
    GROUP BY name
    ORDER BY count DESC
    LIMIT 10
"""

df = client.query(query).to_dataframe()
print(df)
```

---

## Google Cloud Storage (GCS)

### gsutil Commands

```bash
# List buckets
gsutil ls

# List objects
gsutil ls gs://bucket-name/

# Copy to GCS
gsutil cp local-file.txt gs://bucket-name/

# Copy from GCS
gsutil cp gs://bucket-name/file.txt ./

# Sync directory
gsutil -m rsync -r ./local-dir gs://bucket-name/remote-dir
```

### Python Client

```bash
uv pip install google-cloud-storage
```

```python
from google.cloud import storage

# Upload
client = storage.Client()
bucket = client.bucket('my-bucket')
blob = bucket.blob('data.parquet')
blob.upload_from_filename('local-data.parquet')

# Download
blob = bucket.blob('data.parquet')
blob.download_to_filename('downloaded-data.parquet')
```

---

## PySpark with GCS

### Setup

```bash
# Install GCS connector
uv pip install pyspark[gcs]
```

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("GCS Example") \
    .config("spark.jars.packages", "com.google.cloud.bigdataoss:gcs-connector:hadoop3-2.2.11") \
    .config("spark.hadoop.fs.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem") \
    .config("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
    .config("spark.hadoop.google.cloud.auth.service.account.json.keyfile", "/path/to/keyfile.json") \
    .getOrCreate()

# Read from GCS
df = spark.read.parquet("gs://bucket-name/data/*.parquet")

# Write to GCS
df.write.parquet("gs://bucket-name/output/")
```

---

## BigQuery with Spark

### Installation

```bash
uv pip install spark-bigquery-connector
```

### Usage

```python
# Read from BigQuery
df = spark.read \
    .format("bigquery") \
    .option("table", "project.dataset.table") \
    .load()

# Write to BigQuery
df.write \
    .format("bigquery") \
    .option("table", "project.dataset.output_table") \
    .option("temporaryGcsBucket", "temp-bucket") \
    .mode("overwrite") \
    .save()
```

---

## Service Account Authentication

### Create Service Account

```bash
# Create service account
gcloud iam service-accounts create my-sa \
    --display-name="My Service Account"

# Grant roles
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:my-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.admin"

# Create key
gcloud iam service-accounts keys create ~/keys/my-sa-key.json \
    --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/keys/my-sa-key.json"
```

Add to `~/.bashrc`:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/keys/my-sa-key.json"
```

---

## GCP Data Engineering Stack

### Cloud Composer (Managed Airflow)

```bash
# Create environment
gcloud composer environments create my-environment \
    --location=us-central1 \
    --python-version=3

# List environments
gcloud composer environments list
```

### Dataproc (Managed Spark)

```bash
# Create cluster
gcloud dataproc clusters create my-cluster \
    --region=us-central1 \
    --num-workers=2

# Submit Spark job
gcloud dataproc jobs submit pyspark \
    --cluster=my-cluster \
    --region=us-central1 \
    my-script.py
```

---

## Cost Management

### Set Budget Alerts

In GCP Console: Billing → Budgets & alerts

### Check Costs

```bash
# Enable billing export
# Then query in BigQuery:
bq query --use_legacy_sql=false \
  'SELECT service.description, SUM(cost) as total_cost 
   FROM `project.dataset.gcp_billing_export_v1_*`
   WHERE _TABLE_SUFFIX >= FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
   GROUP BY service.description
   ORDER BY total_cost DESC'
```

---

## Local Development with GCP

**Best Practice:**
1. Use service account for local dev
2. Use Workload Identity for GKE
3. Never commit credentials
4. Use Secret Manager for production

**Environment Variables:**

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/keys/dev-sa.json"
export GCP_PROJECT="my-project-dev"
export GCS_BUCKET="my-dev-bucket"
```

---

## Next Steps

- [Data Engineering Tools](06-data-engineering.md)
- [Kubernetes](07-kubernetes.md)

---

**Status:** ✅ Completed - Update with your specific setup as you use it
