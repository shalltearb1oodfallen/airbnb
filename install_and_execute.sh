#!/bin/sh

# change directory
cd data || exit

# build docker image
sudo docker build -t gender_data:latest -f download_data .

# run docker image and download data
sudo docker run --name worldbank_gender_data -v "$(pwd)":/data gender_data https://databank.worldbank.org/data/download/Gender_Stats_CSV.zip

# delete container and image
sudo docker rm worldbank_gender_data && sudo docker image rm gender_data