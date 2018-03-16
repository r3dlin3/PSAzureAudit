function New-AuditAzureAuditTest {
    <#
    .SYNOPSIS
    This function generates a script that contains its tests.

    .DESCRIPTION
    This function generates a script that contains its tests.
    The file is by default placed in the current directory and is called and populated as such
    for a test "EnableHttpsTrafficOnly"

    The script containing the test will be .\EnableHttpsTrafficOnly.Tests.ps1:

    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    . "$here\$sut"

    Describe "Clean" {

        It "does something useful" {
            $true | Should -Be $false
        }
    }


    .PARAMETER Name
    Defines the name of the name of the test to be created.

    .PARAMETER Path
    Defines path where the test should be created, you can use full or relative path.
    If the parameter is not specified the scripts are created in the current directory.

    .EXAMPLE
    New-AuditAzureAuditTest -Name EnableHttpsTrafficOnly

    Creates the scripts in the current directory.

    .EXAMPLE
    New-Fixture C:\Projects\Cleaner Clean

    Creates the script in the C:\Projects\Cleaner directory.

    .EXAMPLE
    New-Fixture Cleaner Clean

    Creates a new folder named Cleaner in the current directory and creates the scripts in it.

    .NOTE
    This function is inspired by New-Fixture cmdlet of Pester
    #>

    param (
        [String]$Path = $PWD,
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $Name = $Name -replace '.ps1',''

    #region File contents
    #keep this formatted as is. the format is output to the file as is, including indentation

    $testCode = '$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace ''\.Tests\.'', ''.''
. "$here\$sut"

Describe "#name#" {
    It "does something useful" {
        $true | Should -Be $false
    }
}' -replace "#name#",$Name

    #endregion

    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

    Create-File -Path $Path -Name "$Name.Audit.ps1" -Content $testCode
}

function Create-File ($Path,$Name,$Content) {
    if (-not (& $SafeCommands['Test-Path'] -Path $Path)) {
        & $SafeCommands['New-Item'] -ItemType Directory -Path $Path | & $SafeCommands['Out-Null']
    }

    $FullPath = & $SafeCommands['Join-Path'] -Path $Path -ChildPath $Name
    if (-not (& $SafeCommands['Test-Path'] -Path $FullPath)) {
        & $SafeCommands['Set-Content'] -Path  $FullPath -Value $Content -Encoding UTF8
        & $SafeCommands['Get-Item'] -Path $FullPath
    }
    else
    {
        # This is deliberately not sent through $SafeCommands, because our own tests rely on
        # mocking Write-Warning, and it's not really the end of the world if this call happens to
        # be screwed up in an edge case.
        Write-Warning "Skipping the file '$FullPath', because it already exists."
    }
}
