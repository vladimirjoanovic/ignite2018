# Deploy an Azure Webapp with custom DNS from Cloudflare using the ARM TerraformOSS RP

The ARM TerraformOSS RP provides access to Cloudflare resources, Cloudflare provides many network related services, one of these is a DNS service with the optional ability for traffic to be proxied via CloudFlare. This template creates a new Azure Webapp running Wordpress and then creaes a custom DNS name at Cloudflare for this site and optionally enables Cloudflares inbound traffic proxy. 

This template shows how to create a web app , hosting plan, application insights and a managed MySQL service. Once these resources are created a DNS CNAME record is created in Cloudflare pointing to this newly created webapp, the CNAME record is validated and added to the webapp and finally the Cloudflare DNS record is updated to enable the proxying of inbound traffic (this is done as a separate step as the Azure Webapp DNS verification fails if the traffic is proxied immediately).

## Pre-requisites

This demo requires a Cloudflare account, a free account can be created at https://www.cloudflare.com/a/sign-up 

It also requires that DNS for a domain is managed by Cloudflare, this can be done by navigating to https://www.cloudflare.com/a/add-site and adding the name of the domain that you wish Cloudflare to manage, once you add the domain Cloudflare will check and import the DNS records for the domain, you then need to change the nameservers for the domain to the Cloudflare nameservers, once done you can now manage the DNS records through Cloudflares API and the TerraformOSS RP.
Once nameservers are set up navigate to https://www.cloudflare.com/a/overview/<yourdomain> and then click on Get your API Key:

![](https://raw.githubusercontent.com/vladimirjoanovic/build2018/master/TerraformOSSRP/Cloudflare/images/cloudflareoverview.png)

The API Key can be obtained by clicking on View Global API Key:

![](https://raw.githubusercontent.com/vladimirjoanovic/build2018/master/TerraformOSSRP/Cloudflare/images/cloudflareapi.png)

## Deploy the template

mySqlAdministratorPassword – the value of the password for the managed mySQL service

webAppName – the name of the web app, this name should be unique, the webapp will be accessible at http://[webAppName].azurewebsites.net 

domain – this is the custom domain managed at Cloudflare

domainnamelabel – this is the domainnamelabel to be used in the custom domain, the web app will be accessible at http://domainnamelabel.domain

email – this is the email sign-in for your Cloudflare account

token -  this is the API Key retrieved above

location – this is the location of the webapp and mysql database

tfRPlocation – this is the location of the Terraform RP resources

proxied – set to true if you want traffic to be proxied via Cloudflare


Once deployment is complete then the same wordpress site should be available at http://[webAppName].azurewebsites.net  and http://[domainnamelabel].[domain]. 

