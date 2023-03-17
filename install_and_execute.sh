#!/bin/sh

# change directory
cd data || exit

# build docker image
sudo docker build -t airbnb:latest -f download_data .

# run docker image and download data
sudo docker run --name airbnb_data_load -v "$(pwd)":/data airbnb https://storage.googleapis.com/airbnb_data_2022/airbnb.zip

# delete container and image
#sudo docker rm airbnb_data_load && sudo docker image rm airbnb
