from google.cloud import bigquery
from google.cloud import storage

# Construct a BigQuery client object.
client = bigquery.Client.from_service_account_json('./key.json')

# Set the destination table.
table_id = 'seismic-aloe-375119.project_airbnb.raw_listings_long'

# Construct a BigQuery job configuration object.
job_config = bigquery.LoadJobConfig(
    skip_leading_rows=1,
    # The source format defaults to CSV, so the line below is optional.
    source_format=bigquery.SourceFormat.CSV,
    field_delimiter=',',
    quote_character='"',
    allow_quoted_newlines=True,
    encoding='UTF-8',
    max_bad_records=0,
    write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
    ignore_unknown_values=True
)

# Construct a Cloud Storage client object.
storage_client = storage.Client.from_service_account_json('./key.json')

# Set the Cloud Storage bucket and directory.
bucket_name = 'project_airbnb_47eedf56'
directory_name = 'files/listings/dec/'

# List all the files in the directory.
blobs = storage_client.list_blobs(bucket_name, prefix=directory_name)

# Load each file into BigQuery.
for blob in blobs:
    uri = f"gs://{bucket_name}/{blob.name}"
    load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)
    load_job.result()
    print(f"Loaded {load_job.output_rows} rows from {uri}")