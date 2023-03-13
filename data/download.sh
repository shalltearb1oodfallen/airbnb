#!/bin/sh

# Check if the filename is provided as argument
if [ $# -eq 0 ]; then
	echo "Please provide the url as an argument."
	exit 1
fi

# Set the filename and download URL
filename=data
url=$1

# Download the file
wget -O $filename.zip "$url"

# Unzip the file to the directory outside of the container
unzip $filename.zip -d /data

# Remove the zip file
rm $filename.zip
