# host specific functions for interacting w/internal services
fpath=(/usr/local/share/zsh-completions $fpath)

function clab-start() {
  docker run --rm -it --privileged                 \
      --network host                               \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /var/run/netns:/run/netns                 \
      --pid="host"                                 \
      -w $CLAB_DIR                                 \
      -v $CLAB_DIR:$CLAB_DIR                       \
      ghcr.io/srl-labs/clab bash
}

