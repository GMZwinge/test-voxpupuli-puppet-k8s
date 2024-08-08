<#
.SYNOPSIS
  Cleanup Bolt project.
.DESCRIPTION
  Cleanup Bolt project.
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
function Remove-IfExist($Path) {
  if (Test-Path $Path) {
    Remove-Item $Path -Recurse
  }
}
Remove-IfExist "$ScriptRoot\.modules"
Remove-IfExist "$ScriptRoot\.resource_types"
Remove-IfExist "$ScriptRoot\.plan_cache.json"
Remove-IfExist "$ScriptRoot\.rerun.json"
Remove-IfExist "$ScriptRoot\.task_cache.json"
Remove-IfExist "$ScriptRoot\bolt-debug.log"
