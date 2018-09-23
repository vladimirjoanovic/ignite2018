
Param(
    [string] [Parameter(Mandatory=$true)] $AppLocation,
    [string] [Parameter(Mandatory=$true)] $AppDefinitionResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $AppDefinitionName,
    [string] $AppName = $AppDefinitionName,
    [string] $ResourceGroupName = "appInstances",
    [string] $ManagedResourceGroupName = "$appName-resources",
    [string] $AppParamJsonFile
)

#if you don't have/want a param file
$AppParamJson = @'
{
  "adminUsername": { "value": "bmoore" },
  "adminPassword": { "value": "Ignite/2018" },
  "_artifactsLocationSasToken": { "value": ""}
}
'@

$AppParamJson = Get-Content $AppParamJsonFile -Raw


#$id = "/subscriptions/ceaedbb7-b827-4195-b55f-de9b6732010b/resourceGroups/appDefinitions/providers/Microsoft.Solutions/applicationDefinitions/ManagedStorage"
#$id = "/subscriptions/ceaedbb7-b827-4195-b55f-de9b6732010b/resourceGroups/appDefintions/providers/Microsoft.Solutions/applicationDefinitions/VMCSEInstallFileBash"
$id = "/subscriptions/" + (Get-AzureRmContext).Subscription.Id +"/resourceGroups/" + $AppDefinitionResourceGroupName + "/providers/Microsoft.Solutions/applicationDefinitions/" + $AppDefinitionName 

$rg = (Get-AzureRmResourceGroup | Where-Object{$_.ResourceGroupName -eq $ResourceGroupName})
if ($rg -eq $null){
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $AppLocation -Verbose -Force -ErrorAction Stop 
}

New-AzureRmManagedApplication -ManagedApplicationDefinitionId $id `
                              -Name $AppName `
                              -ResourceGroupName $ResourceGroupName `
                              -ManagedResourceGroupName $ManagedResourceGroupName `
                              -Location $AppLocation `
                              -Kind ServiceCatalog `
                              -Verbose `
                              -Parameter $appParamJson
