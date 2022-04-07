FROM ubuntu:20.04 AS installer

#ARG INSTALLER="https://xilinx-ax-dl.entitlenow.com/dl/ul/2021/10/24/R210475998/Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz?hash=rNexgEuzUaPIfKXKr8mBYQ&expires=1645657031&filename=Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz"
ARG INSTALLER="Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz"

RUN mkdir /xilinx
WORKDIR /xilinx

RUN uname -a

ADD Xilinx_Vivado_Lab_Lin_2021.2_1021_0703.tar.gz /xilinx/

RUN cd Xilinx_Vivado_* && \
    ./xsetup \
	--agree XilinxEULA,3rdPartyEULA \
	--batch Install \
	--edition "Vivado Lab Edition (Standalone)" \
	--location /installed

FROM ubuntu:20.04

RUN mkdir -p /xilinx/{bin,lib}
RUN echo /xilinx/lib/ >> /etc/ld.so.conf

# hw_server
COPY --from=installer /installed/Vivado_Lab/2021.2/bin/unwrapped/lnx64.o/hw_server /xilinx/bin/
COPY --from=installer /installed/Vivado_Lab/2021.2/lib/lnx64.o/libxftdi.so \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdpcomm.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdjtg.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdftd2xx.so.1 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdabs.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdmgr.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libusb-1.0.so.0 /xilinx/lib/

# xsdb
COPY --from=installer /installed/Vivado_Lab/2021.2/bin/unwrapped/lnx64.o/rdi_xsdb /xilinx/bin/xsdb
COPY --from=installer /installed/Vivado_Lab/2021.2/lib/lnx64.o/libtcl8.5.so \
                      /installed/Vivado_Lab/2021.2/lib/lnx64.o/libtcltcf.so /xilinx/lib/

COPY --from=installer /installed/Vivado_Lab/2021.2/tps/tcl/tcl8.5 \
                     /xilinx/tcl8.5

COPY --from=installer /installed/Vivado_Lab/2021.2/tps/tcl/tcllib1.11.1 \
                     /xilinx/tcllib1.11.1

COPY --from=installer /installed/Vivado_Lab/2021.2/scripts/xsdb \
                     /xilinx/xsdb-lib

RUN ldconfig

ENV TCL_LIBRARY=/xilinx/tcl8.5
ENV TCLLIBPATH="/xilinx/xsdb-lib /xilinx/tcllib1.11.1"

ENV PATH="/xilinx/bin:${PATH}"

CMD ["/xilinx/bin/hw_server"]
