# using ubuntu instead of python slim for broader compatibility
FROM ubuntu:latest

ARG TARGETARCH
ARG GOLANG_VERSION=1.24.5

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
        software-properties-common \
        && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:neovim-ppa/stable && \
    apt-get update && \
    apt-get install -y neovim \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mkdir -p /home/claude/go
RUN chown -R claude:claude /app
RUN chown -R claude:claude /home/claude/go

RUN curl -LO https://golang.org/dl/go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz \
    && rm go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz

USER claude

# install uv (official installer method)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install uv and python tools
RUN /home/claude/.local/bin/uv tool install \
    --with-executables-from ansible-core ansible

RUN /home/claude/.local/bin/uv tool install ansible-lint
RUN /home/claude/.local/bin/uv tool install basedpyright
RUN /home/claude/.local/bin/uv tool install ruff

ENV PATH="/home/claude/.local/bin:/usr/local/go/bin:/home/claude/go/bin:$PATH"

ENV GOROOT=/usr/local/go
ENV GOPATH=/home/claude/go
ENV GOPROXY=direct
RUN go install golang.org/x/tools/gopls@latest

# pull down local neovim bits
RUN mkdir -p /home/claude/.config
RUN git clone https://github.com/sulrich/nvim.git \
    /home/claude/.config/nvim
RUN /home/claude/.local/bin/uv venv /home/claude/.config/nvim/.venv && \
    . /home/claude/.config/nvim/.venv/bin/activate && \
    /home/claude/.local/bin/uv pip install neovim --upgrade && \
    /home/claude/.local/bin/uv pip install pynvim --upgrade && \
    /home/claude/.local/bin/uv pip install basedpyright --upgrade && \
    /home/claude/.local/bin/uv pip install ruff --upgrade
RUN nvim --headless "+Lazy! sync" +qa

# install claude-code stable as native
RUN curl -fsSL https://claude.ai/install.sh | bash


# default command to run on start
CMD ["/bin/bash"]
