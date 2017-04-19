function tc-prepare(
  [ValidateRange(1, 100000)][int] $PrimaryNodePort = 5701,
  [ValidateRange(1, 100000)][int] $SecondaryNodePort = 5702,
  [ValidateRange(1, 100000)][int] $WitnessNodePort = 5703
) {

  if ($PrimaryNodePort -eq $SecondaryNodePort -or $PrimaryNodePort -eq $WitnessNodePort -or $SecondaryNodePort -eq $WitnessNodePort) {
    Write-Error "Port numbers should be different for all the nodes"
    return
  }

  $root = Split-Path -Parent $PSCommandPath

  function Fix-ConfigFile([string] $tmplpath, [string] $cfgpath, [string] $infopath, [int] $port) {
    $tmplpath = $(Resolve-Path $tmplpath).Path
    $content = [IO.File]::ReadAllText($tmplpath)
    $contentNew = $content.Replace("__HOST__", [Environment]::MachineName)
    $contentNew = $contentNew.Replace("__PORT__", $port)
    $contentNew | Out-File -Encoding ascii $cfgpath
    $port | Out-File -Encoding ascii $infopath
  }

  $nodespath = $(Resolve-Path $root\..\..\nodes).Path
  $tmplpath = "$nodespath\rabbitmq.config.tmpl"

  Write-Host -NoNewline "Primary node [$PrimaryNodePort] ... "
  $primaryCfgPath = "$nodespath\primary\rabbitmq.config"
  $primaryInfoPath = "$nodespath\primary\__PORT__"
  Fix-ConfigFile $tmplpath $primaryCfgPath $primaryInfoPath $PrimaryNodePort
  Write-Host "done."

  Write-Host -NoNewline "Secondary node [$SecondaryNodePort] ... "
  $secondaryCfgPath = "$nodespath\secondary\rabbitmq.config"
  $secondaryInfoPath = "$nodespath\secondary\__PORT__"
  Fix-ConfigFile $tmplpath $secondaryCfgPath $secondaryInfoPath $SecondaryNodePort
  Write-Host "done."

  Write-Host -NoNewline "Witness node [$WitnessNodePort ]... "
  $witnessCfgPath = "$nodespath\witness\rabbitmq.config"
  $witnessInfoPath = "$nodespath\witness\__PORT__"
  Fix-ConfigFile $tmplpath $witnessCfgPath $witnessInfoPath $WitnessNodePort
  Write-Host "done."
}
