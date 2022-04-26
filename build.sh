#!/bin/bash

# get tar file
tarfile=$(ls  Xilinx_Vivado_Lab_Lin_*.tar.gz)

# get the version from tar file name
ifsorig=$IFS
IFS='_'
read -ra filenameparts <<< "$tarfile"
IFS=$ifsorig
version=${filenameparts[4]}
echo "Version is $version"

# remove old image
docker-compose stop && docker-compose rm -f
docker image rm -f ghcr.io/sstaehli/hw_server:${version}

# create new image
docker build --build-arg VIVADO_VERSION=${version} --build-arg VIVADO_TAR_FILE=${tarfile} -t ghcr.io/sstaehli/hw_server:${version} --no-cache .

# copy docker-compose file to raspberry pi
#scp docker-compose.yml user@ip:/home/user/