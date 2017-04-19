$root = Split-Path -Parent $PSCommandPath
. $(Resolve-Path "$root\scripts\windows\prepare.ps1").Path
. $(Resolve-Path "$root\scripts\windows\node.ps1").Path
. $(Resolve-Path "$root\scripts\windows\configure.ps1").Path

function label([string] $Message = $(Throw "Message should always be defined")) {
  Write-Host -ForegroundColor Green "`n[ $Message ]"
}

function tc-start() {
  label "Configuring port numbers ..."
  tc-prepare 5701 5702 5703
  label "Starting PRIMARY node ..."
  tc-node primary "rabbitmq-server -detached"
  [Threading.Thread]::Sleep(1000)
  label "Starting SECONDARY node ..."
  tc-node secondary "rabbitmq-server -detached"
  [Threading.Thread]::Sleep(1000)
  label "Starting WITNESS node ..."
  tc-node witness "rabbitmq-server -detached"
  [Threading.Thread]::Sleep(1000)
  label "Cluster nodes status ..."
  tc-node all "rabbitmqctl cluster_status"
  label "Configuring users ..."
  tc-configure primary users
  label "Configuring policies ..."
  tc-configure primary policies
  Write-Output ""
}

function tc-stop() {
  label "Stopping all cluster nodes ..."
  tc-node all "rabbitmqctl stop"
  label "Cleaning git repository ..."
  git clean -d -x -f -- "$root"
  Write-Output ""
}
