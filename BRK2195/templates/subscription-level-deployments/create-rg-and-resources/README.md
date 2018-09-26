# Create a Resource Group And then deploy some resources in it

This is a subscription level template that will create a resource group, create some resources and then optionally assign the contributor role to any principals specified in template parameters.

Currently the only supported methods for deploying subscription level templates are the REST apis, some SDKS and the Azure CLI.  For the latest check [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/create-resource-group-in-template#create-empty-resource-group).

For deploying this template from the CLI you can run the following command from the folder where the sample is located.

```bash
az deployment create -l <location> --template-file azuredeploy.json  --parameters resourceGroupName=<name of new resource group>
```
