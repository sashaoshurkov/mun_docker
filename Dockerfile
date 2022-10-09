FROM golang:1.18 AS builder

RUN apt-get update; \
    apt-get install -y build-essential git jq

RUN git clone https://github.com/munblockchain/mun.git; \
    cd mun; \
    make install

FROM ubuntu:20.04

WORKDIR /root

COPY --from=builder /go/bin/mund /usr/bin
COPY --from=builder /go/bin/mund-manager /usr/bin
COPY --from=builder /go/pkg/mod/github.com/!cosm!wasm/wasmvm@v1.0.0/api/libwasmvm.x86_64.so /usr/lib

EXPOSE 26656 26657 6060 26658 26660 9090 9091

CMD ["/usr/bin/mund-manager", "start", "--pruning=nothing", "--rpc.laddr=tcp://0.0.0.0:26657"]
