FROM ubuntu:24.04
ENV BSC_RELEASE=v1.4.14
RUN apt-get update \
    && apt-get install -y wget unzip
RUN wget https://github.com/bnb-chain/bsc/releases/download/${BSC_RELEASE}/geth_linux -O /usr/local/bin/geth
RUN chmod +x /usr/local/bin/geth

RUN mkdir -p /config/
COPY mainnet.toml /config/mainnet.toml

ENTRYPOINT ["geth"]
