FROM ubuntu:20.04 AS installer

RUN mkdir /xilinx
WORKDIR /xilinx

RUN uname -a

#ARG VIVADO_TAR_FILE="https://xilinx-ax-dl.entitlenow.com/dl/ul/2021/10/24/R210475998/Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz?hash=rNexgEuzUaPIfKXKr8mBYQ&expires=1645657031&filename=Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz"
ARG VIVADO_TAR_FILE="Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz"

ADD ${VIVADO_TAR_FILE} /xilinx/

RUN cd $(basename ${VIVADO_TAR_FILE} .tar.gz) && \
    ./xsetup \
	--agree XilinxEULA,3rdPartyEULA \
	--batch Install \
	--edition "Vivado Lab Edition (Standalone)" \
	--location /installed

FROM ubuntu:20.04

ARG VIVADO_VERSION="2021.2"

RUN mkdir -p /xilinx/bin
RUN mkdir -p /xilinx/lib
RUN echo /xilinx/lib/ >> /etc/ld.so.conf

# hw_server
COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/bin/unwrapped/lnx64.o/hw_server /xilinx/bin/
COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libxftdi.so \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libdpcomm.so.2 \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libdjtg.so.2 \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libdftd2xx.so.1 \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libdabs.so.2 \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libdmgr.so.2 \
                     /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libusb-1.0.so.0 /xilinx/lib/

# XSDB
COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/bin/unwrapped/lnx64.o/rdi_xsdb /xilinx/bin/xsdb
COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libtcl8.5.so \
                      /installed/Vivado_Lab/${VIVADO_VERSION}/lib/lnx64.o/libtcltcf.so /xilinx/lib/

COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/tps/tcl/tcl8.5 \
                     /xilinx/tcl8.5

COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/tps/tcl/tcllib1.11.1 \
                     /xilinx/tcllib1.11.1

COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/scripts/xsdb \
                     /xilinx/xsdb-lib

# Digilent cable data
COPY --from=installer /installed/Vivado_Lab/${VIVADO_VERSION}/data/xicom/cable_data/digilent/lnx64 \
                     /xilinx/digilent_cable

RUN ldconfig

ENV TCL_LIBRARY="/xilinx/tcl8.5"
ENV TCLLIBPATH="/xilinx/xsdb-lib /xilinx/tcllib1.11.1"
ENV DIGILENT_DATA_DIR="/xilinx/digilent_cable"

ENV PATH="/xilinx/bin:${PATH}"

CMD ["/xilinx/bin/hw_server"]
