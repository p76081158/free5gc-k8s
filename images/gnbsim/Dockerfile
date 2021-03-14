FROM golang:1.15.2-buster AS builder

LABEL github="https://github.com/hhorai/gnbsim"

USER root

# Install dependencies
RUN apt-get update && \
    apt-get -y install gcc cmake autoconf libtool pkg-config libmnl-dev libyaml-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

# Clone & Build
    cd $GOPATH/src && \
    git clone https://github.com/p76081158/gnbsim.git && \
    cd gnbsim && \
    make test && \
    make

FROM ubuntu:18.04

# Set working dir
WORKDIR /gnbsim

# Copy executables
COPY --from=builder /go/src/gnbsim/example/example ./test/
COPY --from=builder /go/src/gnbsim/example/example.json ./config/

WORKDIR /gnbsim/test

# Config files volume
VOLUME [ "/gnbsim/config" ]

# Exposed ports
EXPOSE 2152/udp
EXPOSE 38412/sctp
