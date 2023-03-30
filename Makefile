SHELL = /bin/bash -x
# Makefile
.PHONY: infrastructure
.DEFAULT_GOAL := default

default:
	# nothing happens. Choose infrastructure to set up gcs and big query

infrastructure:
	@echo "Building infrastructure"
	sudo docker build -t terraform -f docker/infrastructure . && \
	sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/project_id.txt -v ./infrastructure/set_infrastructure.tf:/app/set_infrastructure.tf terraform;
	
	# build spark container
	sudo docker build -t spark -f docker/spark .

	# build ingestion container
	sudo docker build -t ingestion -f docker/gcs_2_bq .

	# create table on Big Query
	sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/gcs_project.txt -v ./ingestion/raw_listings_long.sql:/app/raw_listings_long.sql -v ./ingestion/raw_listings.sql:/app/raw_listings.sql -v ./ingestion/tables_on_bigquery.py:/app/tables_on_bigquery.py ingestion

	

