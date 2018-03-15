$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$here\TestUtils.ps1"

Load-Module



InModuleScope $ModuleName {
    Describe "Get-ConfigValue" {
        $str = @"
{
    "test1": "foo",
    "test2": {
        "bar" : "this"
    }
}
"@

        $json = $str | ConvertFrom-Json

        It "should return a value" {
            Get-ConfigValue -config $json -KeyPath "test1"  | Should -Be "foo"
            Get-ConfigValue -config $json -KeyPath "test2.bar"  | Should -Be "this"
        }

        It "should return null for an unexisting key" {
            Get-ConfigValue -config $json -KeyPath "foo"  | Should -BeNullOrEmpty
            Get-ConfigValue -config $json -KeyPath "foo.bar"  | Should -BeNullOrEmpty
            Get-ConfigValue -config $json -KeyPath "foo.test1"  | Should -BeNullOrEmpty
        }
    }

    Describe "Set-ConfigValue" {
        BeforeEach {
            $str = @"
            {
                "test1": "foo",
                "test2": {
                    "bar" : "this"
                }
            }
"@
            
            $json = $str | ConvertFrom-Json
        }


        It "should add a value" {
            Set-ConfigValue -config $json -KeyPath "test3" -value "VALUE"
            $json.test3 | Should -Be "VALUE"
        }

        It "should overwrite a value" {
            Set-ConfigValue -config $json -KeyPath "test1" -value "VALUE"
            $json.test1 | Should -Be "VALUE"
        }

        It "should add a value to a full path" {
            Set-ConfigValue -config $json -KeyPath "test3.testa" -value "VALUE"
            $json.test3.testa | Should -Be "VALUE"
        }

        It "should add a value to a sub path" {
            Set-ConfigValue -config $json -KeyPath "test2.testa" -value "VALUE"
            $json.test2.testa | Should -Be "VALUE"
        }

        It "should create a full path for an empty object" {
            $json = "{}" | ConvertFrom-Json
            Set-ConfigValue -config $json -KeyPath "test1.testa" -value "VALUE"
            $json.test1.testa | Should -Be "VALUE"
        }
    }
}
