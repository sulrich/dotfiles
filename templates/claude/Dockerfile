# using ubuntu instead of python slim for broader compatibility
FROM ubuntu:latest

RUN useradd -m claude

# install system dependencies including python
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        nodejs \
        npm \
        curl \
        git \
        && rm -rf /var/lib/apt/lists/*

# create python symlink for compatibility
RUN ln -s /usr/bin/python3 /usr/bin/python

# install uv (official installer method)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# add uv to PATH for all users
ENV PATH="/root/.local/bin:$PATH"

# install claude-code
RUN npm install -g @anthropic-ai/claude-code

# create a system-wide virtual environment for ansible tools and install packages
RUN /root/.local/bin/uv venv /opt/ansible-venv && \
    . /opt/ansible-venv/bin/activate && \
    /root/.local/bin/uv pip install ansible ansible-lint

WORKDIR /app

RUN chown -R claude:claude /app

USER claude

# ensure uv is available and activate ansible venv for claude user
ENV PATH="/opt/ansible-venv/bin:/home/claude/.local/bin:/root/.local/bin:$PATH"

# default command to run on start
CMD ["/bin/bash"]
