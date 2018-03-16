# Test file for the PSAzureAudit module - https://github.com/r3dlin3/PSAzureAudit/
# Called via Invoke-AzureAudit 

# Test title, e.g. 'HttpsTrafficOnly'
$Title = 'HTTPS Traffic Only'

# Test description
$Description = 'Check if HTTPS Traffic is enforced'

# The config entry stating the desired values
$DesiredKey = "storage.EnableHttpsTrafficOnly"


# The test value's data type, to help with conversion: bool/string/int
$Type = 'int'

# Storage, SQLDatabase, SQLServer, Logging, Networking, VM, Security
$Area = "Storage"

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    [int]$Object
}

