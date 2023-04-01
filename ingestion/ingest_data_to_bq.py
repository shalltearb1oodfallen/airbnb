import sys

from google.cloud import bigquery, storage

with open("./project_id.txt", "r") as f:
    id = f.read()

bq_table = sys.argv[1]

quarter = sys.argv[2]

if bq_table == "raw_listings_long":
    path = "listings"
else:
    path = "non_listings"

table = id + ".project_airbnb." + bq_table


def load_listings(key, table, directory):
    # BigQuery client
    client = bigquery.Client.from_service_account_json(key)
    table_id = table
    job_config = bigquery.LoadJobConfig(
        skip_leading_rows=1,
        source_format=bigquery.SourceFormat.CSV,
        field_delimiter=",",
        quote_character='"',
        allow_quoted_newlines=True,
        encoding="UTF-8",
        max_bad_records=0,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        ignore_unknown_values=True,
    )

    # Construct a Cloud Storage client object.
    storage_client = storage.Client.from_service_account_json(key)
    # Find airbnb project
    buckets = storage_client.list_buckets()
    for bucket in buckets:
        if "project_airbnb" in bucket.name:
            bucket_name = bucket.name

    directory_name = f"files/{directory}"

    # List all the files in the directory.
    blobs = storage_client.list_blobs(bucket_name, prefix=directory_name)

    # Load each file into BigQuery.
    for blob in blobs:
        uri = f"gs://{bucket_name}/{blob.name}"
        load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)
        load_job.result()
        print(f"{load_job.output_rows} rows inserted from {blob.name}")


load_listings("./key.json", table, f"{path}/{quarter}")
