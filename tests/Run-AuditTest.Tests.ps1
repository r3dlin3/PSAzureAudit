$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$global:here\TestUtils.ps1"

Load-Module
Write-Verbose "global:here=$global:here"

InModuleScope $ModuleName {
    Describe "Run-AuditTest" {
    Context "String" {
        $str = @"
    {
        "foo": {
            "bar" : "foobar"
        }
    }
"@
    
        $config = $str | ConvertFrom-Json
        
        Run-AuditTest -Config $config -InputObject "dummy" -FileTestPath "$global:here\TestString.Audit.ps1"

        $str = @"
            {
                "foo": {
                    "bar" : "WRONG"
                }
            }
"@
            
        $config = $str | ConvertFrom-Json
        Run-AuditTest -Config $config -InputObject "dummy" -FileTestPath "$global:here\TestString.Audit.ps1"

        $str = @"
            {
                "foo": {
                    
                }
            }
"@
            
        $config = $str | ConvertFrom-Json
        Run-AuditTest -Config $config -InputObject "dummy" -FileTestPath "$global:here\TestString.Audit.ps1"
    }
}
}