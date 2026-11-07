# -*- Mode: shell-script; tab-width: 2 -*- *
# host specific environment configuration

# to be used on select macos hosts
export SSH_AUTH_SOCK="${HOME}/.1password/agent.sock"

# amazon AWS vars - default, might be overrident by direnv
export AWS_DEFAULT_PROFILE="sulrich@nexthop.ai"

# wastebin url - default, might be overridden by direnv
export WBIN_API_URL="http://paste.sw.internal.nexthop.ai"

# obsidian shit
export OBSIDIAN_HOME="${HOME}/src/obsidian/nexthop"
