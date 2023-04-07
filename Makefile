SHELL = /bin/bash -x
# Makefile
.PHONY: infrastructure
.DEFAULT_GOAL := default

default:
	# nothing happens. Choose infrastructure to set up gcs and big query

key:
	@echo "create keys"
	echo "/home/shalltear/.ssh/seismic-aloe-375119-2472ead814ee.json" > key.txt
	echo "seismic-aloe-375119" > gcs_project.txt

docker:
	@echo "update docker to newest version"
	sh .docker/update_docker.sh

infrastructure:
	@echo "Building infrastructure"
	sudo docker build -t terraform -f docker/infrastructure . && \
	sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/project_id.txt -v ./infrastructure/set_infrastructure.tf:/app/set_infrastructure.tf terraform;
	
	# build spark container
	sudo docker build -t spark -f docker/spark .

	# build raw tables container
	sudo docker build -t raw_tables -f docker/raw_tables .

	# build ingestion container
	sudo docker build -t ingestion -f docker/ingestion .

	# create table on Big Query
	sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/gcs_project.txt -v ./infrastructure/raw_listings_long.sql:/app/raw_listings_long.sql -v ./infrastructure/raw_listings.sql:/app/raw_listings.sql -v ./infrastructure/tables_on_bigquery.py:/app/tables_on_bigquery.py raw_tables
	
	# create dbt container
	sudo docker build -t dbt -f docker/dbt .

	# create dbt profile file
	sudo docker build -t dbt_profile -f docker/dbt_profile . 
	sudo docker run --rm -it -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/project_id.txt -v ./infrastructure/create_dbt_profile.py:/app/create_dbt_profile.py -v ./dbt:/file dbt_profile

pipeline:
	@echo "Execute the complete pipeline: loading data to gcs, to big query and run dbt"
	# load data to gcs by using spark
	sudo docker run --rm -v $$(cat key.txt):/home/jovyan/key.json -v $$(pwd)/spark/data_to_gcs.py:/home/jovyan/data_to_gcs.py -e SPARK_HOME=/usr/local/spark -e PYSPARK_PYTHON=/opt/conda/bin/python spark /bin/bash -c "export PYTHONPATH=$SPARK_HOME/python/lib/py4j-0.10.9-src.zip:$SPARK_HOME/python:$PYTHONPATH && python /home/jovyan/data_to_gcs.py";
	for month in mar jun sep dec; do \
		sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./ingestion/ingest_data_to_bq.py:/app/ingest_data_to_bq.py -v ./gcs_project.txt:/app/project_id.txt ingestion python ingest_data_to_bq.py raw_listings $$month; \
		sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./ingestion/ingest_data_to_bq.py:/app/ingest_data_to_bq.py -v ./gcs_project.txt:/app/project_id.txt ingestion python ingest_data_to_bq.py raw_listings_long $$month; \
		sudo docker run --rm -it -v ./dbt/:/app -v $$(cat key.txt):/app/key.json dbt && rm -f ./dbt/key.json; \
	done