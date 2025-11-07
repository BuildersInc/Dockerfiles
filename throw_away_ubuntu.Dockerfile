FROM ubuntu:24.04

# Launch
# docker run --network host -it --rm wegwerf-linux-dev

# Transfer Files
# On Host
# cd to the directory
# python -m http.server -b 127.0.0.1 8000

# In the docker env
# wget http://host.docker.internal:8000/<file>

ENV DEBIAN_FRONTEND=noninteractive

# System aktualisieren und notwendige Tools installieren
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        wget \
        git \
        vim \
        nano \
        less \
        net-tools \
        iproute2 \
        iputils-ping \
        dnsutils \
        procps \
        htop \
        lsof \
        file \
        python3 \
        python3-pip \
        build-essential \
        pkg-config \
        man-db && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["/bin/bash"]
