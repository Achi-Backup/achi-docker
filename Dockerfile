FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM xterm

# Global packages
RUN apt-get update && apt-get install -y \
    git \
    nano \
    python3 \
    python3.8-venv \
    sudo \
    && rm -r /var/lib/apt/lists/*

# Set system timezone to UTC
ENV TZ="UTC"
RUN apt-get update && apt-get install -y tzdata \
    && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Achi
ENV ACHI_ROOT="/root/.achi/mainnet"
ENV ACHI_KEYS="persistent"
ENV ACHI_PLOTS_DIR="/plots"
ENV FARMER_ADDRESS="null"
ENV FARMER_PORT="null"

# Full node port
EXPOSE 9975
# Full not RPC port
EXPOSE 9965

ARG BRANCH=master
RUN git clone --branch ${BRANCH} https://github.com/Achi-Coin/achi-blockchain /achi-blockchain \
    && cd /achi-blockchain \
    && chmod +x install.sh \
    && ./install.sh \
    && . ./activate \
    && achi init \
    && deactivate

ENV PATH=/achi-blockchain/venv/bin:$PATH
WORKDIR /achi-blockchain

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]