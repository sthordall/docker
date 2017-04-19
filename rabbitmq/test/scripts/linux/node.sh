#!/bin/bash

function tc-node {

  function usage {
    echo ""
    echo "Usage: $1 \$node \$cmd..."
    echo "  \$node = (primary|secondary|witness|all)"
    echo "  \$cmd... = any command can follow"
  }

  if [ $# -le 1 ]; then
    echo >&2 "ERROR: Missing arguments"
    usage $FUNCNAME
    return
  fi
  node=$(echo $1 | tr '[:upper:]' '[:lower:]')
  if [[ ! "$node" =~ ^(primary|secondary|witness|all)$ ]]; then
    echo >&2 "ERROR: Node can only have following values: primary, secondary, witness or all"
    usage $FUNCNAME
    return
  fi

  primaryNode=(primary)
  secondaryNode=(secondary)
  witnessNode=(witness)
  allNodes=(primary secondary witness)
  declare -A parameters=(
    ["primary"]=${primaryNode[@]}
    ["secondary"]=${secondaryNode[@]}
    ["witness"]=${witnessNode[@]}
    ["all"]=${allNodes[@]}
  )

  commands=("${@:2}")

  function runWithNodeEnvironment {
    node=$1
    root=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    nodepath=$(realpath $root/../../nodes/$node)
    if [ ! -f $nodepath"/__PORT__" ]; then
      echo >&2 "WARNING: $node node is not configured and thus will be skipped"
      return
    fi
    read port < $nodepath"/__PORT__"
    # NOTE (linux): it's impossible to set custom path to .erlang.cookie file on linux
    # NOTE (linux): due to limitation of rabbitmq-server and rabbitmqctl scripts
    # NOTE (linux): thus using default file for all nodes: /var/lib/rabbitmq/.erlang.cookie
    # NOTE (linux): as a result following lines commented out (it works on Windows platform through)
    export RABBITMQ_NODENAME="rabbit-$node@$(hostname)"
    export RABBITMQ_NODE_PORT=$port
    export RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,1$port}]"
    export RABBITMQ_CONFIG_FILE=$nodepath"/rabbitmq"
    export RABBITMQ_MNESIA_BASE=$nodepath"/mnesia"
    export RABBITMQ_LOG_BASE=$nodepath"/logs"
    export RABBITMQ_ENABLED_PLUGINS_FILE=$nodepath"/enabled_plugins"
    for i in "${commands[@]}"; do
      sudo --preserve-env $i
    done
  }

  items="${parameters["$node"]}"
  for i in $items; do
    # yellow='\033[1;33m'
    # reset='\033[0m'
    # echo -e "${yellow}>>> $i${reset}"
    runWithNodeEnvironment $i
  done

  return
}
