FROM node:20
RUN useradd -m gemini

ARG TARGETARCH

# install system dependencies including python
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        git \
        jq \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN chown -R gemini:gemini /app
RUN npm install -g @google/gemini-cli

USER gemini

# install uv (official installer method) - as gemini user
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install uv and python tools
RUN /home/gemini/.local/bin/uv tool install \
    --with-executables-from ansible-core ansible && \
    /home/gemini/.local/bin/uv tool install ansible-lint && \
    /home/gemini/.local/bin/uv tool install ruff

ENV PATH="/home/gemini/.local/bin:$PATH"

# default command to run on start
CMD ["/bin/bash"]
