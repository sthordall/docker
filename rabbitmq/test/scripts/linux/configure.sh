#!/bin/bash

function tc-configure {

  function usage {
    echo ""
    echo "Usage: $1 \$node \$type"
    echo "  \$node = (primary|secondary|witness)"
    echo "  \$type = (users|policies)"
  }

  if [ $# -ne 2 ]; then
    echo >&2 "ERROR: Missing arguments"
    usage $FUNCNAME
    return
  fi
  node=$(echo $1 | tr '[:upper:]' '[:lower:]')
  if [[ ! "$node" =~ ^(primary|secondary|witness)$ ]]; then
    echo >&2 "ERROR: Node can only have following values: primary, secondary or witness"
    usage $FUNCNAME
    return
  fi
  section=$(echo $2 | tr '[:upper:]' '[:lower:]')
  if [[ ! "$section" =~ ^(users|policies)$ ]]; then
    echo >&2 "ERROR: Type can only have following values: users or policies"
    usage $FUNCNAME
    return
  fi

  root=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  . $root"/node.sh"

  commands=()

  # users
  if [ "$section" = "users" ]; then
    commands=(
    )
    # enable admin as administrator
    commands+=("rabbitmqctl add_user admin admin")
    commands+=("rabbitmqctl set_permissions admin (.*) (.*) (.*)")
    commands+=("rabbitmqctl set_user_tags admin administrator")
    # enable user1 as normal user
    commands+=("rabbitmqctl add_user user1 passwd1")
    commands+=("rabbitmqctl set_permissions user1 (.*) (.*) (.*)")
    # disable guest account
    commands+=("rabbitmqctl set_user_tags guest")
  fi

  # policies
  if [ "$section" = "policies" ]; then
    policy="{\"ha-sync-mode\":\"automatic\",\"ha-mode\":\"nodes\",\"ha-params\":[\"rabbit-primary@HOST\",\"rabbit-secondary@HOST\"]}"
    def=${policy//@HOST/@$(hostname)}
    commands+=("rabbitmqctl set_policy -p / --priority 0 --apply-to queues SyncMirrorQueues \".*\" $def")
  fi

  tc-node $node "${commands[@]}"
}
