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
.PARAMETER NodeType
  Whether to provision the target as a Kubernetes control plane node (ctrl) or worker node.
.PARAMETER ControlPlaneUrl
  The url to the control plane.
.PARAMETER EtcdServerUrl
  The url to the etcd server.
.PARAMETER Secret16Char
  The 16 characters secret.
#>
[CmdletBinding()]
Param(
  [string]$Target = 'server',
  [string]$User = 'user',
  [string]$Pass = 'pass',
  [ValidateSet('controller', 'worker')]
  [string]$NodeType = 'worker',
  [string]$ControlPlaneUrl = 'https://kubernetes:6443',
  [string]$EtcdServerUrl = 'https://kubernetes:2379',
  [string]$Secret16Char = '0123456789abcdef'
)
$Script:ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
trap { throw $Error[0] }
if (-not $MyInvocation.BoundParameters.ContainsKey('Verbose')) {
  $VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}
$ScriptRoot = $PSScriptRoot
#
# Get shared variables.
. "$PSScriptRoot\_Shared.ps1"
#
Write-Verbose 'Running plan...'
# TODO: could log the std out and err of the bolt command inside the container,
# may need to override the entry point and run the whole bolt command itself,
# possibly through a shell, then redirect ouputs using the parameters
#   > bolt-plan-run-std.log 2>&1
$BaseCommand = "docker container run --mount 'type=bind,source=$DockerMountSource,destination=$DockerMountDestination'" +
  " --workdir '$DockerMountDestination' --rm --env 'BOLT_PROJECT=$DockerMountDestination' '$BoltDockerImage'" +
  " plan run '${BoltProjectName}::myplan' --targets '$Target'" +
  " --verbose" +
  " --user '$User' --password '$Pass' --inventory 'inventory.yaml' 'node_type=$NodeType'" +
  " 'control_plane_url=$ControlPlaneUrl' 'etcd_server_url=$EtcdServerUrl' 'secret_16_char=$Secret16Char'"
$OutputFile = "$ScriptRoot\Build-plan-run-$Target-verbose.log"
# Send command to output file so that I can easily copy and paste to run it again.
'',$BaseCommand,'' | Out-File $OutputFile -Encoding ascii -Append
$Command = "$BaseCommand | Out-File '$OutputFile' -Encoding ascii -Append"
#$Command = $BaseCommand
Write-Verbose $Command
Invoke-Expression $Command
