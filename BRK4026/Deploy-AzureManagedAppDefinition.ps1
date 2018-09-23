
Param(
    [string] [Parameter(Mandatory=$true)] $ArtifactStagingDirectory,
    [string] [Parameter(Mandatory=$true)] $AppLocation,
    [string] $ResourceGroupName = "appDefinitions",
    [string] $AppName = $ArtifactStagingDirectory.replace('.\',''), #remove .\ if present
    [string] $StorageAccountName,
    [string] $StorageContainerName = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $DisplayName = $AppName,
    [string] $Description = $AppName,
    [ValidateSet("None", "ReadOnly")][string]$LockType = "ReadOnly",
    [string] $ServicePrincipalObjectId,
    [ValidateSet("Contributor", "Owner")]
    [string] $role = "Contributor"

)

switch ($role)
 {
    "Owner" {$roleId = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635" }
    "Contributor" {$roleId = "b24988ac-6180-42a0-ab88-20f7382dd24c"}
 }

if (!$ServicePrincipalObjectId) {
    $ServicePrincipalObjectId =(Get-AzureRmADUser -UserPrincipalName (Get-AzureRmContext).Account.Id).id.guid
}

$authorization = $ServicePrincipalObjectId + ":" + $roleId
#$authorization = "7c1752e8-668a-4aed-9405-20d1e9daf1e6:$roleId" #bmoore
$authorization = "c0adf779-cb97-42dd-8636-d4ab620fb654:$roleId" #sp

$packageFileName = $ArtifactStagingDirectory + "\application.zip"
$packagesFiles = $ArtifactStagingDirectory + "\*.*"

#update this to exlude parameter files see -LiteralPath arg
Compress-Archive -Path $packagesFiles -DestinationPath $packageFileName -Force

$StorageAccountName = 'stage' + ((Get-AzureRmContext).Subscription.Id).Replace('-', '').substring(0, 19)
$StorageAccount = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName})

# Create the storage account if it doesn't already exist
if ($StorageAccount -eq $null) {
    $StorageResourceGroupName = 'ARM_Deploy_Staging'
    New-AzureRmResourceGroup -Location "$AppLocation" -Name $StorageResourceGroupName -Force
    $StorageAccount = New-AzureRmStorageAccount -StorageAccountName $StorageAccountName -Type 'Standard_LRS' -ResourceGroupName $StorageResourceGroupName -Location "$AppLocation"
}

New-AzureStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue *>&1

Set-AzureStorageBlobContent -Container $StorageContainerName -File $packageFileName  -Context $storageAccount.Context -Force

$PackageUri = New-AzureStorageBlobSASToken -Container $StorageContainerName -Blob (Split-Path $packageFileName -leaf) -Context $storageAccount.Context -FullUri -Permission r   

$rg = (Get-AzureRmResourceGroup | Where-Object{$_.ResourceGroupName -eq $ResourceGroupName})
if ($rg -eq $null){
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $AppLocation -Verbose -Force -ErrorAction Stop 
}

New-AzureRmManagedApplicationDefinition -Name $appName `
                                        -ResourceGroupName $ResourceGroupName `
                                        -DisplayName $displayName `
                                        -Description $description `
                                        -Location $AppLocation `
                                        -LockLevel $LockType `
                                        -PackageFileUri $PackageUri `
                                        -Authorization $authorization `
                                        -Verbose