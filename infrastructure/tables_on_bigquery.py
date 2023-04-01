from google.cloud import bigquery


def create_table(key, project_id, sql_file):
    # Read project id
    with open(project_id, "r") as f:
        id = f.read()

    # Create BigQuery client object
    client = bigquery.Client.from_service_account_json(key, project=id)

    # Read SQL script from file
    with open(sql_file, "r") as f:
        create_table_command = f.read()

    # Execute CREATE TABLE command on BigQuery
    create_table_job = client.query(create_table_command)

    # Wait for the job to complete
    create_table_job.result()


create_table("key.json", "gcs_project.txt", "raw_listings_long.sql")

create_table("key.json", "gcs_project.txt", "raw_listings.sql")
