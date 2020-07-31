FROM ubuntu:latest as qfstest
WORKDIR /root/
COPY . .
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    bison \
    build-essential \
    cmake \
    default-jdk \
    flex \
    git \
    g++ \
    libboost-regex-dev \
    libssl-dev \
    libkrb5-dev \
    libfuse-dev \
    libz-dev \
    pkg-config \
    psmisc \
    maven \
    yasm
RUN [ "/bin/bash" , "-c" , "make build && \
    make test QFSTEST_OPTIONS=-noauth && \
    ./test-lost-chunks.sh" ]