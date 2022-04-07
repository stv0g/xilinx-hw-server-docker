# Xilinx hw_server & xsdb Docker Image

This Docker image allows you to run Xilinx's `hw_server` as well as the Xilinx debugger `xsdb` in a Docker container.
Using QEmu user-space emulation, these tools can also run on embedded devices like a Raspberry Pi or the Ultra-scale boards themself.

- [Blog article with details](https://noteblok.net/2022/02/23/running-a-xilinx-hw_server-as-docker-container/)

![Setup](./docs/setup.png)

## Tested Vivado versions

- [v2021.2](https://github.com/stv0g/xilinx-hw-server-docker/pkgs/container/hw_server/18536381?tag=v2021.2)

## Tested systems

- Raspberry Pi 4 with 64-bit Raspberry Pi OS (Debian Bullseye)

## Usage

```bash
docker run --rm --restart unless-stopped --privileged --volume /dev/bus/usb:/dev/bus/usb --publish 3121:3121 --detach ghcr.io/stv0g/hw_server
```

## Running on non x86_64 systems

```bash
# Install docker
sudo apt-get update && sudo apt-get upgrade
curl -sSL https://get.docker.com | sh

sudo systemctl enable --now docker

# Enable qemu-user emulation support for running amd64 Docker images
docker run --rm --privileged aptman/qus -s -- -p x86_64

# Run the hw_server
docker run --rm --restart unless-stopped --privileged --volume /dev/bus/usb:/dev/bus/usb --publish 3121:3121 --detach ghcr.io/stv0g/hw_server
```

## Building your own image

1. Download the _Vivado Lab Solutions_ Linux installer to the current directory.
   - **Do not extract it!**
   - E.g. `Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz`
2. Build the image:

```bash
docker build --tag hw_server --build-arg INSTALLER=Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz .
```
