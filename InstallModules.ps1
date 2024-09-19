<#
.SYNOPSIS
  Install modules.
.DESCRIPTION
  Install modules.
#>
[CmdletBinding()]
Param(
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
Write-Verbose 'Installing modules...'
$Command = "docker container run --mount 'type=bind,source=$DockerMountSource,destination=$DockerMountDestination'" +
  " --workdir '$DockerMountDestination' --rm --env 'BOLT_PROJECT=$DockerMountDestination' '$BoltDockerImage'" +
  " module install --force"
Write-Verbose $Command
Invoke-Expression $Command
if ($LASTEXITCODE -ne 0) {
  throw "This command failed with exit code ${LASTEXITCODE}: $Command"
}
