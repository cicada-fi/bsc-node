FROM ubuntu:24.04
ENV DOWNLOAD_URL=https://snapshots.48.club/geth.fast.42563551.tar.zst
ENV SAVE_DIR=/data/bsc/snapshots
ENV SAVE_FILE=mainnet.tar.zst
ENV SHA_256=b4e940a67e63b0f6292517ff309572711921319f1eb2378e98d950ac6db38882
ENV EXTRACT_DIR=/data/bsc/mainnet
ENV ACT_DOWNLOAD=1
ENV ACT_CHECKSUM=1
ENV ACT_EXTRACT=1
WORKDIR /app
RUN apt-get update \
    && apt-get install -y wget zstd aria2 openssl
COPY extract.sh extract_non_interactive.sh ./
ENTRYPOINT ["/bin/bash", "/app/extract.sh"]
