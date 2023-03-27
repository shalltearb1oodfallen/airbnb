SHELL = /bin/bash -x
# Makefile
.PHONY: infrastructure
.DEFAULT_GOAL := default

default:
	# nothing happens. Choose infrastructure to set up gcs and big query

infrastructure:
	@echo "Building Terraform and Spark container and running Terraform"
	# build terraform container
	FILEPATH=$$(read -p "Please enter the complete path and name of your json key to gcp: " && echo $$REPLY) && \
	sudo docker build -t terraform -f docker/infrastructure . && \
	echo "FILEPATH=$${FILEPATH}" && \
	sudo docker run --rm -v $${FILEPATH}:/app/key.json -v ./infrastructure/set_infrastructure.tf:/app/set_infrastructure.tf terraform; \
	# build spark container
	sudo docker build -t spark -f docker/spark .	