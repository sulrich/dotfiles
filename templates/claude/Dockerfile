# is there a lighter container that fits the bill here?
FROM python:3.11-slim

RUN useradd -m claude

RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app

RUN chown -R claude:claude /app

USER claude

# default command to run on start
CMD ["/bin/bash"]
