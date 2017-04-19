#!/bin/bash

function tc-prepare {

  function usage {
    echo ""
    echo "Usage: $1"
    echo "  \$pnPort = primary node port defaults to 5701"
    echo "  \$snPort = secondary node port defaults to 5702"
    echo "  \$wnPort = witness node port defaults to 5703"
    echo ""
    echo "Usage: $1 \$pnPort \$snPort \$wnPort"
    echo "  \$pnPort = primary node port"
    echo "  \$snPort = secondary node port"
    echo "  \$wnPort = witness node port"
  }

  if [[ $# != 3 && $# != 0 ]]; then
    echo >&2 "ERROR: Illegal arguments"
    usage $FUNCNAME
    return
  fi
  pnPort="5701"
  snPort="5702"
  wnPort="5703"
  if [ $# -eq 3 ]; then
    pnPort=$1
    snPort=$2
    wnPort=$3
  fi
  if ! [[ $pnPort =~ ^[0-9]+ ]] ; then
    echo >&2 "ERROR: port number should be a number ('$pnPort' instead was supplied)"
    usage $FUNCNAME
    return
  fi
  if ! [[ $snPort =~ ^[0-9]+ ]] ; then
    echo >&2 "ERROR: port number should be a number ('$snPort' instead was supplied)"
    usage $FUNCNAME
    return
  fi
  if ! [[ $wnPort =~ ^[0-9]+ ]] ; then
    echo >&2 "ERROR: port number should be a number ('$wnPort' instead was supplied)"
    usage $FUNCNAME
    return
  fi
  if [[ $pnPort == $snPort || $pnPort == $wnPort || $snPort == $wnPort ]]; then
    echo >&2 "ERROR: ports for all three nodes should be different"
    usage $FUNCNAME
    return
  fi

  root=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

  # 1) path to template config file
  # 2) path to real config file (might not exist)
  # 3) path to info file (might not exist)
  # 4) port number
  function fixConfigFile {
    tmplpath=$(realpath $1)
    cfgpath=$(realpath $2)
    infopath=$(realpath $3)
    port=$4
    auxpath=$cfgpath.new
    if [ -f $auxpath ]; then rm $auxpath; fi
    oldIFS=$IFS; IFS=''
    while read line; do
      line=${line//__HOST__/$(hostname)}
      line=${line//__PORT__/$port}
      echo "$line" >> $auxpath
    done < $tmplpath
    IFS=$oldIFS
    mv $auxpath $cfgpath
    echo "$port" > $infopath
  }

  nodespath=$(realpath $root/../../nodes)
  tmplpath="$nodespath/rabbitmq.config.tmpl"

  echo "Setting permission to ./nodes/**/logs and ./nodes/**/mnesia folders"
  sudo chmod o+w -R $nodespath/**/logs
  sudo chmod o+w -R $nodespath/**/mnesia

  echo -n "Primary node [$pnPort] ... "
  primaryCfgPath="$nodespath/primary/rabbitmq.config"
  primaryInfoPath="$nodespath/primary/__PORT__"
  fixConfigFile $tmplpath $primaryCfgPath $primaryInfoPath $pnPort
  echo "done."

  echo -n "Secondary node [$snPort] ... "
  secondaryCfgPath="$nodespath/secondary/rabbitmq.config"
  secondaryInfoPath="$nodespath/secondary/__PORT__"
  fixConfigFile $tmplpath $secondaryCfgPath $secondaryInfoPath $snPort
  echo "done."

  echo -n "Witness node [$wnPort] ... "
  witnessCfgPath="$nodespath/witness/rabbitmq.config"
  witnessInfoPath="$nodespath/witness/__PORT__"
  fixConfigFile $tmplpath $witnessCfgPath $witnessInfoPath $wnPort
  echo "done."
}
