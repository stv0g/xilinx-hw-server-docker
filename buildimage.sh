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
docker image rm -f xilinx-hw_server-docker:${version}

# create new image
docker build --build-arg VIVADO_VERSION=${version} --build-arg VIVADO_TAR_FILE=${tarfile} -t xilinx-hw_server-docker:${version} --no-cache .

# save image in tar file
docker save xilinx-hw_server-docker:${version} > xhwsd.tar

# copy image to raspberry pi
#scp xhwsd.tar user@ip:/home/user/

# on target -> load image
#ssh user@ip "docker load < xhwsd.tar"