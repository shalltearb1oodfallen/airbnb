from google.cloud import bigquery

with open("gcs_project.txt", "r") as f:
    id = f.read()

with open("raw_listings.sql", "r") as f:
    create_table_command = f.read()

with open("raw_listings_long.sql", "r") as f:
    create_table_command_long = f.read()


def create_table(key, id, sql_file):
    # Create BigQuery client object
    client = bigquery.Client.from_service_account_json(key, project=id)

    # Execute CREATE TABLE command on BigQuery
    create_table_job = client.query(sql_file)

    # Wait for the job to complete
    create_table_job.result()


create_table("key.json", id, create_table_command)

create_table("key.json", create_table_command, create_table_command_long)
