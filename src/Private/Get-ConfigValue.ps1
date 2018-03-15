
function Get-ConfigValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $Config,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty ()]
        [string]
        $KeyPath
    )
    $current = $config
    $old=$config
    foreach($key in $KeyPath.Split('.')) {
        
        if (! ($current.PSobject.Properties.name -match $key )) {
            Write-Warning "Missing Key $key in $KeyPath"
            return
        } else {
            Write-Verbose "Key $key already exists"
        }
        $old=$current
        $current=$current.$key

    }
    $val = $old.$key
    Write-Verbose "Get-ConfigValue: Returning $val for $KeyPath"
    $val
}