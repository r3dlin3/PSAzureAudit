<#
.SYNOPSIS
Run an audit based on its path

#>
function Run-AuditTest {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,

        [Parameter(Mandatory=$true)]
        [string]
        $FileTestPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        $Config

    )
    Write-Verbose "Processing test file $FileTestPath"
    $TestName = Split-Path $FileTestPath -Leaf


    # Pull in $Title/$Description/$Desired/$Type/$Actual/$Fix from the test file
    . $FileTestPath
    $Desired = Get-ConfigValue -Config $Config -Key $DesiredKey
    # Pump the brakes if the config value is $null
    $skip=$false
    If ($Desired -eq $null) {
        Write-Verbose "Due to null config value, skipping test $TestName"
        # Use return to skip this test 
        #return
        $skip=$true
    }

    It -Name "$Title" -Skip:$skip -Test {
       
        # "& $Actual" is running the first script block to compare to $Desired
        # The comparison should be empty
        # (meaning everything is the same, as expected)
        $Result = (& $Actual -as $Type)
        
        
        #allow for $Desired to be a scriptblock vs simple value
        if ($Desired.GetType().name -eq 'scriptblock') {
            $Desired = (& $Desired -As $Type)
        }
        #Compare-Object -ReferenceObject $Desired -DifferenceObject $Result |
        #    Should BeNullOrEmpty
        $Result | Should -BeExactly $Desired
    } #It 
}