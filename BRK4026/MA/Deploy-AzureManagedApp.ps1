
Param(
    [string] [Parameter(Mandatory=$true)] $AppLocation,
    [string] [Parameter(Mandatory=$true)] $AppDefinitionName,
    [string] [Parameter(Mandatory=$true)] $AppParamJsonFile,
    [string] $AppDefinitionResourceGroupName = "appDefinitions",
    [string] $AppName = $AppDefinitionName,
    [string] $ResourceGroupName = "appInstances",
    [string] $ManagedResourceGroupName = "$appName-resources"
)

$AppParamJson = Get-Content $AppParamJsonFile -Raw

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
