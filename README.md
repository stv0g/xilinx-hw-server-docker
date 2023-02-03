# Xilinx hw_server & xsdb Docker Image

This Docker image allows you to run Xilinx's `hw_server` as well as the Xilinx debugger `xsdb` in a Docker container.
Using QEmu user-space emulation, these tools can also run on embedded devices like a Raspberry Pi or the Ultra-scale boards themself.

- [Blog article with details](https://noteblok.net/2022/02/23/running-a-xilinx-hw_server-as-docker-container/)

![Setup](./docs/setup.png)

## Tested Vivado versions

- [v2021.2](https://github.com/users/sstaehli/packages/container/hw_server/20585701?tag=2021.2)
- [v2020.1](https://github.com/users/sstaehli/packages/container/hw_server/20585725?tag=2020.1)

## Tested systems

- Raspberry Pi 4 with 64-bit Raspberry Pi OS (Debian Bullseye)

## Usage

### Docker

```bash
docker run \
   --rm \
   --restart unless-stopped \
   --privileged \
   --volume /dev/bus/usb:/dev/bus/usb \
   --publish 3121:3121 \
   --detach \
   ghcr.io/stv0g/hw_server:v2021.2
```

### Docker-compose

Copy the `docker-compose.yml` file from this repo to your target's working directory and run the following command to start the container.

```bash
docker-compose up -d
```

## Running on non x86_64 systems

```bash
# Install docker
sudo apt-get update && sudo apt-get upgrade
curl -sSL https://get.docker.com | sh

sudo systemctl enable --now docker

# Optional: Install docker-compose (with Python3)
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip
‍sudo pip3 install docker-compose

# Enable qemu-user emulation support for running amd64 Docker images
docker run --rm --privileged aptman/qus -s -- -p x86_64

# Run the hw_server with docker
docker run --rm --restart unless-stopped --privileged --volume /dev/bus/usb:/dev/bus/usb --publish 3121:3121 --detach ghcr.io/sst/hw_server:2021.2

# - OR -

# Run the hw_server with docker-compose (copy the docker-compose.yml to your working dir first)
docker-compose up -d
```

The following steps are not necessary if you use docker-compose.

### Optional: Enable QEmu userspace emulation at system startup

```bash
cat > /etc/systemd/system/qus.service <<EOF
[Unit]
Description=Start docker container for QEMU x86 emulation
Requires=docker.service
After=docker.service

[Service]
Type=forking
TimeoutStartSec=infinity
Restart=no
ExecStart=/usr/bin/docker run --rm --privileged aptman/qus -s -- -p x86_64

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now qus
```

The above steps in conjunction with the docker restart policy will make your `hw_server` container start whenever your system is booted.

If you want to let systemd manage the hw_server you can use also do the following

```bash
cat > /etc/systemd/system/hw_server.service <<EOF
[Unit]
Description=Starts xilinx hardware server
After=docker-qemu-interpreter.service
Requires=docker.service

[Service]
Type=forking
PIDFile=/run/hw_server.pid
TimeoutStartSec=infinity
Restart=always
ExecStart=/usr/bin/docker run --rm --name hw_server --privileged  --platform linux/amd64 --volume /dev/bus/usb:/dev/bus/usb --publish 3121:3121 --detach ghcr.io/stv0g/hw_server:v2021.2
ExecStartPost=/bin/bash -c '/usr/bin/docker inspect -f '{{.State.Pid}}' hw_server | tee /run/hw_server.pid'
ExecStop=/usr/bin/docker stop hw_server

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hw_server
```

## Building your own image

1. Download the _Vivado Lab Solutions_ Linux installer to the current directory.
   - **Do not extract it!**
   - E.g. `Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz`
2. Build the image with the [build.sh](build.sh) script:

   ```bash
   ./build.sh
   ```

### Note concerning Accept EULA

Depending on the Vivado version, you have to agree WebTalk (e. g. Version 2020.1) in the [Dockerfile](Dockerfile) or omit it (e. g. Version 2021.2). If this particular line does not match, Vivado installation will fail!

#### For 2021.2 and future versions

```bash
...
--agree XilinxEULA,3rdPartyEULA \
...
```

#### For 2020.1 and probably older versions

```bash
...
--agree XilinxEULA,3rdPartyEULA,WebTalkTerms \
...
```
