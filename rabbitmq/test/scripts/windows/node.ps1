function tc-node(
  [ValidateSet("Primary", "Secondary", "Witness", "All")][string] $NodeType = $(Throw "Node type should always be supplied"),
  [string[]] $Commands = $(Throw "Commands should always be supplied")
) {

  $parameters = @{
    "primary" = @("primary");
    "secondary" = @("secondary");
    "witness" = @("witness");
    "all" = @("primary", "secondary", "witness");
  }

  function Run-WithNodeEnvironment([string] $node, [string[]] $cmds) {
    $root = Split-Path -Parent $PSCommandPath
    $nodepath = $(Resolve-Path $root\..\..\nodes\$node).Path
    if (-not $(Test-Path "$nodepath\__PORT__")) {
      Write-Warning "$node node is not configured and thus will be skipped"
      return
    }
    $port = @(Get-Content "$nodepath\__PORT__")[0]
    $Env:HOMEDRIVE = $(Resolve-Path $root).Drive.Name + ":\"
    $Env:HOMEPATH = $nodepath.Substring(3)
    $Env:RABBITMQ_NODENAME = "rabbit-$node@" + [Environment]::MachineName
    $Env:RABBITMQ_NODE_PORT = $port
    $Env:NODE_HOME_DIR = $nodepath
    $Env:RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,1$port}]"
    $Env:RABBITMQ_CONFIG_FILE = "$nodepath\rabbitmq"
    $Env:RABBITMQ_MNESIA_BASE = "$nodepath\mnesia"
    $Env:RABBITMQ_LOG_BASE = "$nodepath\logs"
    $Env:RABBITMQ_ENABLED_PLUGINS_FILE = "$nodepath\enabled_plugins"
    $cmds | % { Invoke-Expression $PSItem }
  }

  $oldHOMEDRIVE = $Env:HOMEDRIVE
  $oldHOMEPATH = $Env:HOMEPATH

  try {
    $parameters[$NodeType.ToLower().Trim()] | % {
      $node = $PSItem
      # Write-Host $(" >>> $node") -ForegroundColor Yellow
      Run-WithNodeEnvironment $node $Commands
    }
  }
  finally {
    $Env:HOMEDRIVE = $oldHOMEDRIVE
    $Env:HOMEPATH = $oldHOMEPATH
  }
}
