# FROM ubuntu:latest
FROM node:24

RUN useradd -m augment

# install system dependencies including python
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        curl \
        git \
        gh \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN chown -R augment:augment /app

RUN npm install -g @augmentcode/auggie

USER augment

ENV PATH="/home/agument/.local/bin:/root/.local/bin:$PATH"

# default command to run on start
CMD ["/bin/bash"]
