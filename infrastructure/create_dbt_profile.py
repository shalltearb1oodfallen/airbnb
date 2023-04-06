import yaml

with open("/app/project_id.txt", "r") as f:
    id = f.read()

data = {
    "dbt_project": {
        "outputs": {
            "dev": {
                "dataset": "project_airbnb",
                "job_execution_timeout_seconds": 999,
                "job_retries": 1,
                "keyfile": "/app/key.json",
                "method": "service-account",
                "priority": "interactive",
                "project": id,
                "threads": 4,
                "type": "bigquery",
            }
        },
        "target": "dev",
    }
}

with open("/file/profiles.yml", "w") as file:
    documents = yaml.dump(data, file)
