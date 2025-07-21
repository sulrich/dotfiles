# is there a lighter container that fits the bill here?
FROM node:20

RUN useradd -m gemini

RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @google/gemini-cli

WORKDIR /app

RUN chown -R gemini:gemini /app

USER gemini

# default command to run on start
CMD ["/bin/bash"]
