function tc-configure(
  [Parameter(Mandatory=$true)][ValidateSet("Primary", "Secondary", "Witness")][string] $NodeType,
  [Parameter(Mandatory=$true)][ValidateSet("Users", "Policies")][string] $Section
) {

  $commands = @()

  # users
  if ($Section -imatch "Users") {
    # enable admin as administrator
    $commands += @("rabbitmqctl add_user admin admin")
    $commands += @("rabbitmqctl set_permissions admin ""(.*)"" ""(.*)"" ""(.*)""")
    $commands += @("rabbitmqctl set_user_tags admin administrator")
    # enable user1 as normal user
    $commands += @("rabbitmqctl add_user user1 passwd1")
    $commands += @("rabbitmqctl set_permissions user1 ""(.*)"" ""(.*)"" ""(.*)""")
    # disable guest account
    $commands += @("rabbitmqctl set_user_tags guest")
  }

  # policies
  if ($Section -imatch "Policies") {
    $def = $("{\`"ha-sync-mode\`":\`"automatic\`",\`"ha-mode\`":\`"nodes\`",\`"ha-params\`":[\`"rabbit-primary@HOST\`",\`"rabbit-secondary@HOST\`"]}").Replace("`@HOST", [Environment]::MachineName)
    $commands += @("cmd /C 'rabbitmqctl set_policy -p / --priority 0 --apply-to queues SyncMirrorQueues \`".*\`" `"$def`" '")
  }

  tc-node $NodeType $commands
}
