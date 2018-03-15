
$ModuleName = "PSAzureAudit"
Write-Verbose "ModuleName=$ModuleName"
$ModuleFolder = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Verbose "ModuleFolder=$ModuleFolder"
$ModulePath = Join-Path $ModuleFolder "$ModuleName.psm1"
Write-Verbose "ModulePath=$ModulePath"

function Load-Module {
    Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $ModulePath -Force -ErrorAction Stop
}