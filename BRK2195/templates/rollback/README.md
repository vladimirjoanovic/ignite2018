# Demo using on error deployment to rollback to previous state in the event of an error during a deployment

## Overview

This set of templates show how to use the on_error_deployment property to deploy a previous template in the event of an error during template deployment.

The on_error_deployment property of a deployment is used to specify the name of a previous deployment that should be automatically submitted in the event of an error in a deployment, the previous deployment must have succeeded, the string 'last_successful' can be used as shorthand for the name of the last successful deployment in a resource group. This mechanism enables resources in a resource group to be returned to a previous state if an error occurs in a deployment.

Note that re-applying a previous deployment will not neccessarily return that resource expressed in that deployment, for example removing a custom script extension from a VM will not reverse the changes made by the custom script extension.

There are 4 seperate demos

- [How to remove all resources in a resource group after an error occurs](###how-to-remove-all-resources-in-resource-group-after-an-error-occurs)
- [How to remove all resources in a resource group except those from a specific template](###-how-to-remove-all-resources-in-a-resource-group-except-those-from-a-specific-template)
- How to ensure that the properties of a resource are reset to their previous value and leave all other resources unchanged
- Removing a custom script extension

## Instructions

### How to remove all resources in resource group after an error occurs

1. Set up a resource group to be used for the demo

``` bash
    az group create --name rollback-demo --location northeurope
```

2. Deploy a template with no resources

    Deploying a template with no resources in complete mode enables that deployment to be specified as the deployment to rollback to, because the template has no resources defined in it and it is deployed in complete mode when it is executed it will remove any resources in the resource group

``` bash
    az group deployment create --resource-group rollback-demo --template-file empty-template.json --mode Complete
```

3. Deploy a template that fails specifying the flag --rollback-on-error

``` bash
    az group deployment create --name rollmeback --resource-group rollback-demo --template-file failing-template.json --rollback-on-error
```

    This template will create a storage account using a name dervied from the resource group id and deployment name , this first resource should be successfully created, next it will try and create a storage account with an invalid name, this will fail as the name has uppercase characters, this failure will cause the last successful deployment to run ((as the option --rollback-on-error is specified without an argument)). As this deployment creates no resources and is deployed in complete mode the all resources in the resource group are deleted.

4. Show the status of the deployment

```bash
    az group deployment show --name rollmeback --resource-group rollback-demo
```

    This command will show the state of the deployment that failed, you should see that the onErrorDeployment property is set and contains details of the deployment run as a result of the error:

```json
    "onErrorDeployment": {
      "deploymentName": "empty-template<timestamp>",
      "provisioningState": "Succeeded",
      "type": "LastSuccessful"
    }
```

5. Get details of the status of the on error deployment

```bash
    az group deployment show --name empty-template<timestamp> --resource-group rollback-demo
```

### How to remove all resources in a resource group except those from a specific template

1. Deploy a template to create a storage account in the resource group

```bash
    az group deployment create --resource-group rollback-demo --template-file create-storage-account.json --name storage-account-1 --mode Complete --parameters @storage-account-parameters-1.json
```

2. Deploy the same template again to create a storage account with a different name

```bash
    az group deployment create --resource-group rollback-demo --template-file create-storage-account.json --name storage-account-2 --mode Incremental --parameters @storage-account-parameters-2.json
```

3. List the resources in the resource group

```bash
    az resource list --resource-group rollback-demo
```

    Listing the resources will show that there are now two storage accounts in the resource group.

4. Deploy a template that fails and rollback to the first deployment

``` bash
    az group deployment create --name rollmeback --resource-group rollback-demo --template-file failing-template.json --rollback-on-error storage-account-1
```

    In this example when the deployment fails rather than run the last successful deployment the name of the first deployment is specified as an argument to the option --rollback-on-error, as this first deployment was deployed in complete mode it has the effect of deleting the storage account in the second deployment.


5. List the resources in the resource group

```bash
    az resource list --resource-group rollback-demo
```

    Listing the resources will show that there is now only one storage account in the resource group.

6. Show the status of the deployment that failed

```bash
    az group deployment show --name rollmeback --resource-group rollback-demo
```

    This command will show the state of the deployment that failed, you should see that the on 

```json
    "onErrorDeployment": {
      "deploymentName": "storage-account-1<timestamp>",
      "provisioningState": "Succeeded",
      "type": "LastSuccessful"
    }
```

### How to ensure that the properties of a resource are reset to their previous value and leave all other resources unchanged

### Clean Up

Delete the resource group to clean everything up

``` bash
az group delete --name rollback-demo
```