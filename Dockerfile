FROM ubuntu:20.04 AS installer

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

RUN echo /xilinx/lib/ >> /etc/ld.so.conf

COPY --from=installer /installed/Vivado_Lab/2021.2/bin/unwrapped/lnx64.o/hw_server \
		      /installed/Vivado_Lab/2021.1/bin/xsdb \
		      /installed/Vivado_Lab/2021.1/bin/setupEnv.sh \
		      /installed/Vivado_Lab/2021.1/bin/loader /xilinx/bin/
COPY --form=installer /installed/Vivado_Lab/2021.1/bin/unwrapped/lnx64.o/rlwrap \
		      /installed/Vivado_Lab/2021.1/bin/unwrapped/lnx64.o/rdi_xsdb /xilinx/bin/unwrapped/lnx64.o/
COPY --from=installer /installed/Vivado_Lab/2021.2/lib/lnx64.o/libxftdi.so \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdpcomm.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdjtg.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdftd2xx.so.1 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdabs.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libdmgr.so.2 \
                     /installed/Vivado_Lab/2021.2/lib/lnx64.o/libusb-1.0.so.0 /xilinx/lib/


RUN ldconfig

CMD ["/xilinx/bin/hw_server"]
