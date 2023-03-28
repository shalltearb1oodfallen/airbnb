SHELL = /bin/bash -x
# Makefile
.PHONY: infrastructure
.DEFAULT_GOAL := default

default:
	# nothing happens. Choose infrastructure to set up gcs and big query

infrastructure:
	@echo "Building Terraform and Spark container and running Terraform"
	# build terraform container
	sudo docker build -t terraform -f docker/infrastructure . && \
	sudo docker run --rm -v $$(cat key.txt):/app/key.json -v ./gcs_project.txt:/app/project_id.txt -v ./infrastructure/set_infrastructure.tf:/app/set_infrastructure.tf terraform;
	# build spark container
	sudo docker build -t spark -f docker/spark .	