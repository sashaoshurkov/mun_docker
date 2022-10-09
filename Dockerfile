FROM golang:1.18 AS builder

RUN apt-get update; \
    apt-get install -y build-essential git

RUN git clone https://github.com/munblockchain/mun.git; \
    cd mun; \
    make install

FROM ubuntu:20.04

WORKDIR /root

COPY --from=builder /go/bin/mund /usr/bin
COPY --from=builder /go/bin/mund-manager /usr/bin

EXPOSE 26656 26657 6060 26658 26660 9090 9091

CMD ["/bin/sh", "-c", "mund"]
