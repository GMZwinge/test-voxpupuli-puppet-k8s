<#
.SYNOPSIS
  Apply Bolt project to targets.
.DESCRIPTION
  Apply Puppet Bolt project to given target.
.PARAMETER Target
  The target of the apply.
.PARAMETER User
  The user to connect to the target.
.PARAMETER Pass
  The password to connect to the target.
.PARAMETER Type
  Whether to provision the target as a Kubernetes control plane node (ctrl) or worker node.
#>
[CmdletBinding()]
Param(
  [string]$Target = 'server',
  [string]$User = 'user',
  [string]$Pass = 'pass',
  [ValidateSet('controller', 'worker')]
  [string]$Type = 'worker'
)
$Script:ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
trap { throw $Error[0] }
if (-not $MyInvocation.BoundParameters.ContainsKey('Verbose')) {
  $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}
$ScriptRoot = $PSScriptRoot
#
Write-Verbose 'Installing modules...'
# The Puppet Bolt image:
$BoltDockerImage = 'puppet/puppet-bolt:3.27.4'
# Project names can contain only lowercase letters, numbers, and underscores, and begin with a lowercase letter.
$BoltProjectName = 'test_voxpupuli_puppet_k8s'
$DockerMountDir = "/$BoltProjectName"
# Mount source must be an absolute path.
$DockerMountSource = $ScriptRoot
$Command = "docker container run --mount 'type=bind,source=$DockerMountSource,destination=$DockerMountDir'" +
  " --workdir '$DockerMountDir' --rm --env 'BOLT_PROJECT=$DockerMountDir' '$BoltDockerImage'" +
  " module install --force"
Write-Verbose $Command
Invoke-Expression $Command
if ($LASTEXITCODE -ne 0) {
  throw "This command failed with exit code ${LASTEXITCODE}: $Command"
}
#
Write-Verbose 'Running plan...'
$BaseCommand = "docker container run --mount 'type=bind,source=$PWD,destination=$DockerMountDir'" +
  " --workdir '$DockerMountDir' --rm --env 'BOLT_PROJECT=$DockerMountDir' '$BoltDockerImage'" +
  " --verbose plan run '${BoltProjectName}::myplan' --targets '$Target'" +
  " --user '$User' --password '$Pass' --inventory 'inventory.yaml' 'type=$Type'"
#$OutputFile = "$ScriptRoot\Build-plan-run-$Target-verbose-1.log"
# Send command to output file so that I can easily copy and paste to run it again.
#$BaseCommand | Out-File $OutputFile -Encoding ascii
#$Command = "$BaseCommand | Out-File '$OutputFile' -Encoding ascii -Append"
$Command = $BaseCommand
Write-Verbose $Command
Invoke-Expression $Command
