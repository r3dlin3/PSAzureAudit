[cmdletbinding()]
Param()

Describe "Storage Accounts" {
    Get-AzureRmStorageAccount | ForEach-Object {
        Context "$($_.StorageAccountName) in $($_.ResourceGroupName)" {
            It "Enable data encryption is transit." {
                $_.EnableHttpsTrafficOnly | Should -Be $True
            }

            It "Enable data encryption at rest for blobs." {
                $_.Encryption.Services.Blob | Should -Be $True
            }
<#
            It "Regenerate storage account access keys periodically."  {

                Get-AzureRmLog -ResourceId $_.Id -StartTime (Get-Date).AddDays(-90) -Status Succeeded `
                    | where {$_.OperationName.Value -eq "Microsoft.Storage/storageAccounts/regenerateKey/action"} `
                    | Should -Not -BeNullOrEmpty
            }
#>
            It "Enable data encryption at rest for file service." {
                $_.Encryption.Services.File | Should -Be $True
            }
            It "Disable anonymous access to blob containers." {
                $key1 = (Get-AzureRmStorageAccountKey -ResourceGroupName $_.ResourceGroupName -name $_.StorageAccountName)[0].value
                $ctx = New-AzureStorageContext -StorageAccountName $_.StorageAccountName -StorageAccountKey $key1
                
                $containers = Get-AzureStorageContainer -Context $ctx 
                foreach($container in $containers) {
                    Write-Verbose "PublicAccess for $($container.name): $($container.PublicAccess)"
                    $container.PublicAccess | Should -Be "Off"
                }
            }

        } # Context
    } #ForEach

} # Describe