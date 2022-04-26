#!/bin/bash

# Get the Vivado installer tar file
VIVADO_TAR_FILE=$(ls  Xilinx_Vivado_Lab_Lin_*.tar.gz)

# Get the version from tar file name
IFS_ORIG=${IFS}
IFS='_'
read -ra FILENAME_PARTS <<< "${VIVADO_TAR_FILE}"
IFS=${IFS_ORIG}

VIVADO_VERSION=${FILENAME_PARTS[4]}
echo "Version is ${VIVADO_VERSION}"

# Create new image
docker build \
    --build-arg VIVADO_VERSION=${VIVADO_VERSION} \
    --build-arg VIVADO_TAR_FILE=${VIVADO_TAR_FILE} \
    --tag ghcr.io/stv0g/hw_server:${VIVADO_VERSION} \
    .
