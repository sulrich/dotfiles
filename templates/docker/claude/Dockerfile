# using ubuntu instead of python slim for broader compatibility
FROM ubuntu:latest

ARG TARGETARCH

RUN useradd -m claude

# install system dependencies including python
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        nodejs \
        npm \
        python3 \
        python3-venv \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN chown -R claude:claude /app

USER claude

# install uv (official installer method)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install uv and python tools
RUN /home/claude/.local/bin/uv tool install \
    --with-executables-from ansible-core ansible && \
    /home/claude/.local/bin/uv tool install ansible-lint && \
    /home/claude/.local/bin/uv tool install ruff

ENV PATH="/home/claude/.local/bin:$PATH"

# install claude-code stable as native
RUN curl -fsSL https://claude.ai/install.sh | bash

# default command to run on start
CMD ["/bin/bash"]
