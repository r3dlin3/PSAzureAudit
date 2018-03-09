
function Invoke-AzureAudit {
    <#
    .SYNOPSIS
    Test (and fix) configuration in Azure.

    .DESCRIPTION
    Invoke-AzureAudit will run each test it finds and report on discrepancies.
    It compares actual values against the values you supply in a config file,
    and can fix them immediately if you include the -Remediate parameter.

    If you are not already connected to Azure defined in the
    config file, Invoke-AzureAudit will prompt for credentials to connect to it.

    Invoke-AzureAudit then calls Pester to run each test file. The test files
    leverage Azure PowerShell to gather values for comparison/remediation.


    .INPUTS
    [System.Object]
    Accepts piped input (optional multiple objects) for parameter -Config

    .NOTES
    This command relies on the Pester for testing.
    
    .LINK
    https://github.com/r3dlin3/PSAzureAudit
    #>
    [CmdletBinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'Medium')]
    # ^ that passes -WhatIf through to other tests
    param (
        # Optionally define a different config file to use
        # Defaults to \Vester\Configs\Config.json
        [Parameter(ValueFromPipeline = $True,
                   ValueFromPipelinebyPropertyName=$True)]
        [ValidateScript({
            If ($_.FullName) {Test-Path $_.FullName}
            Else {Test-Path $_}
        })]
        [Alias('FullName')]
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json",

        # Optionally define the file/folder of test file(s) to call
        # Defaults to \Vester\Tests\, grabbing all tests recursively
        # All test files must be named *.Vester.ps1
        #[ValidateScript({
        #    If ($_.FullName) {Test-Path $_.FullName}
        #    Else {Test-Path $_}
        #})]
        #[Alias('Path','Script')]
        #[object[]]$Test = (Get-VesterTest -Simple),

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false,

        # Optionally save Pester output in NUnitXML format to a specified path
        # Specifying a path automatically triggers Pester in NUnitXML mode
        [ValidateScript({Test-Path (Split-Path $_ -Parent)})]
        [object]$XMLOutputFile,

        # Optionally returns the Pester result as an object containing the information about the whole test run, and each test
        # Defaults to false (disabled)
        [switch]$PassThru = $false
    )

    PROCESS {
        # -Test should accept directories and objects
        If ($Test[0] -notlike '*.Vester.ps1') {
            If ($Test[0].FullName) {
                # Strip Get-Item/Get-ChildItem/Get-VesterTest object to path only
                $Test = $Test.FullName
            } Else {
                # This is a directory. Get the Vester tests here
                $Test = $Test | Get-VesterTest -Simple
            }
        }

        ForEach ($ConfigFile in $Config) {
            # Gracefully handle Get-Item/Get-ChildItem
            If ($ConfigFile.FullName) {
                $ConfigFile = $ConfigFile.FullName
            }
            Write-Verbose -Message "Processing Config file $ConfigFile"

            # Load the defined $cfg values to test
            # -Raw needed for PS v3/v4
            $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json

            If (-not $cfg) {
                throw "Valid config data not found at path '$ConfigFile'. Exiting"
            }

            # Check for established session to desired vCenter server
            If ($cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {
                Try {
                    # Attempt connection to vCenter; prompts for credentials if needed
                    Write-Verbose "No active connection found to configured vCenter '$($cfg.vcenter.vc)'. Connecting"
                    $VIServer = Connect-VIServer -Server $cfg.vcenter.vc -ErrorAction Stop
                } Catch {
                    # If unable to connect, stop
                    throw "Unable to connect to configured vCenter '$($cfg.vcenter.vc)'. Exiting"
                }
            } Else {
                $VIServer = $global:DefaultVIServers | Where-Object {$_.Name -match $cfg.vcenter.vc}
            }
            Write-Verbose "Processing against vCenter server '$($cfg.vcenter.vc)'"
            #Build Pester Parameter Hashtable to splat
            $Pester_Params = @{
                Script = @{
                    Path = "$(Split-Path -Parent $PSScriptRoot)\Private\Template\VesterTemplate.Tests.ps1"
                    Parameters = @{
                        Cfg       = $cfg
                        TestFiles = $Test
                        Remediate = $Remediate
                    }#Parameters
                }#Script
            }#Pester_Params

            If ($XMLOutputFile) {
                $Pester_Params += @{
                   OutputFormat = "NUnitXml"
                   OutputFile = $XMLOutputFile
                   
                }#Pester_Params
            } 
            # Call Invoke-Pester based on the parameters supplied
            # Runs VesterTemplate.Tests.ps1, which constructs the .Vester.ps1 test files
            Invoke-Pester @Pester_Params -PassThru:$PassThru
            # In case multiple config files were provided and some aren't valid
            $cfg = $null
        } #ForEach Config
    } #Process
} #function
