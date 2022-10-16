FROM golang:1.18 AS builder

RUN apt-get update; \
    apt-get install -y build-essential git; \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

RUN git clone https://github.com/munblockchain/mun.git; \
    cd mun; \
    git checkout main; \
    make install; \
    make clean; \
    cd .. && rm -rf mun

FROM ubuntu:20.04

WORKDIR /root

COPY --from=builder /usr/local/go/bin/go /usr/local/go/bin/go
COPY --from=builder /go /go

ENV PATH="/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV GOPATH="/go"

EXPOSE 26656 26657 6060 26658 26660 9090 9091

CMD ["mund", "start", "--pruning=nothing", "--rpc.laddr=tcp://0.0.0.0:26657"]