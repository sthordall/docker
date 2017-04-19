#!/bin/bash

root=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $root"/scripts/linux/prepare.sh"
. $root"/scripts/linux/node.sh"
. $root"/scripts/linux/configure.sh"

function label {
  echo ""
  green='\033[0;32m' # '\e[1;32m' is too bright for white bg.
  reset='\033[0m'
  echo -e "${green}[ $* ]${reset}"
}

function tc-start {
  label "Configuring port numbers ..."
  tc-prepare 5701 5702 5703
  label "Starting PRIMARY node ..."
  tc-node primary "rabbitmq-server -detached"
  sleep 3s
  label "Starting SECONDARY node ..."
  tc-node secondary "rabbitmq-server -detached"
  sleep 3s
  label "Starting WITNESS node ..."
  tc-node witness "rabbitmq-server -detached"
  sleep 3s
  label "Cluster nodes status ..."
  tc-node all "rabbitmqctl cluster_status"
  label "Configure users ..."
  tc-configure primary users
  label "Configure policies ..."
  tc-configure primary policies
  echo ""
}

function tc-stop {
  label "Stopping all cluster nodes ..."
  tc-node all "rabbitmqctl stop"
  label "Cleaning git repository ..."
  p=$(realpath $root/../..)
  sudo -E git clean -d -x -f -- "$p"
  echo ""
}
