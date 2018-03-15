
function Set-ConfigValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $Config,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty ()]
        [string]
        $KeyPath,
        [Parameter(Mandatory=$true)]
        $Value
    
    )
    $current = $config
    $old = $config

    $KeyPath.Split('.') | ForEach-Object{
        $key=$_
        if (! ($current.PSobject.Properties.name -match $key ) ){
            Write-Verbose "Adding key $key"
            $current | Add-Member -Type NoteProperty -Name $key -Value (New-Object PSCustomObject)

        } else {
            Write-Verbose "Key $key already exists"
        }
        $old=$current
        $current=$current.$key

    }
    $old.$key = $Value
    
}