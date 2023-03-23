# SQL Managed Instance Deployment Checklist

This GitHub repo contains a Checklist and sample Scripts for enterprise SQL Managed Instance deployments

Possible involved Roles: 

- AADAdmin
- NetworkAdmin
- DatabaseAdmin
- EngineeringOpsAdmin
- EngineeringOps

### EngineeringOpsAdmin Creates Resource groups

EngineeringOpsAdmin Creates Resource group for SQL MI vNet (if not already exists) and Resource group to SQL MI instance (if not already exists)

- EngineeringOpsAdmin adds a role assignment of “SQL Managed Instance Contributor” in the SQL MI vNet Resource group (i.e. ContosoAzureEastUSsqlmiVNetTest3) and selects the EngineeringOps user performing the deployment

![smicontributor](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/smicontributor.png)

- EngineeringOpsAdmin adds a role assignment of "Network Contributor" in the SQL MI vNet Resource group (i.e. ContosoAzureEastUSsqlmiVNetTest3ContosoAzureEastUSsqlmiVNetTest3) and selects the NetworkAdmin user performing the vNet deployment

![netcontributor](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/netcontributor.png)

- EngineeringOpsAdmin adds a role assignment of “SQL Managed Instance Contributor” in the SQL MI instance Resource group (i.e. DevContosoAzureEastUSsqlmiTest3) and selects the EngineeringOps user performing the deployment

![smicontributor](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/smicontributor.png)


### NetworkAdmin creates SQL MI network resources in the SQL MI vNet Resource group 

Use a Azure CLI script [3-CreateSQLMIvNet.sh](https://github.com/DataSnowman/sqlmideployment/blob/main/scripts/cli/3-CreateSQLMIvNet.sh) or (PowerShell, portal, etc.) similar to this:

```
#!/bin/bash

# Create an Azure SQL Managed Instance virtual network

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="eastus"
resourceGroup="ContosoAzureEastUSsqlmiVNetTest2"
tag="create-managed-instance"
vNet="ContosoAzureEastUSsqlmiVNetTest2"
subnet="DevelopmentSQLMIsubnetTest2"
nsg="nsg-ContosoAzureEastUSsqlmiVNetTest2"
route="route-ContosoAzureEastUSsqlmiVNetTest2"

echo "Using resource group $resourceGroup"

echo "Creating $resourceGroup in $location..."
az group create --name $resourceGroup --location "$location" --tags $tag 

echo "Creating $vNet with $subnet..."
az network vnet create --name $vNet --resource-group $resourceGroup --location "$location" --address-prefixes 10.198.0.0/24
az network vnet subnet create --name $subnet --resource-group $resourceGroup --vnet-name $vNet --address-prefixes 10.198.0.0/25 --delegations Microsoft.Sql/managedInstances

echo "Creating $nsg..."
az network nsg create --name $nsg --resource-group $resourceGroup --location "$location"

az network nsg rule create --name "allow_management_inbound" --nsg-name $nsg --priority 100 --resource-group $resourceGroup --access Allow --destination-address-prefixes 10.198.0.0/25 --destination-port-ranges 9000 9003 1438 1440 1452 --direction Inbound --protocol Tcp --source-address-prefixes "*" --source-port-ranges "*"
az network nsg rule create --name "allow_misubnet_inbound" --nsg-name $nsg --priority 200 --resource-group $resourceGroup --access Allow --destination-address-prefixes 10.198.0.0/25 --destination-port-ranges "*" --direction Inbound --protocol "*" --source-address-prefixes 10.198.0.0/25 --source-port-ranges "*"
az network nsg rule create --name "allow_health_probe_inbound" --nsg-name $nsg --priority 300 --resource-group $resourceGroup --access Allow --destination-address-prefixes 10.198.0.0/25 --destination-port-ranges "*" --direction Inbound --protocol "*" --source-address-prefixes AzureLoadBalancer --source-port-ranges "*"
az network nsg rule create --name "allow_management_outbound" --nsg-name $nsg --priority 1100 --resource-group $resourceGroup --access Allow --destination-address-prefixes AzureCloud --destination-port-ranges 443 12000 --direction Outbound --protocol Tcp --source-address-prefixes 10.198.0.0/25 --source-port-ranges "*"
az network nsg rule create --name "allow_misubnet_outbound" --nsg-name $nsg --priority 200 --resource-group $resourceGroup --access Allow --destination-address-prefixes 10.198.0.0/25 --destination-port-ranges "*" --direction Outbound --protocol "*" --source-address-prefixes 10.198.0.0/25 --source-port-ranges "*"

echo "Creating $route..."
az network route-table create --name $route --resource-group $resourceGroup --location "$location"

az network route-table route create --address-prefix 0.0.0.0/0 --name "primaryToMIManagementService" --next-hop-type Internet --resource-group $resourceGroup --route-table-name $route
az network route-table route create --address-prefix 10.198.0.0/25 --name "ToLocalClusterNode" --next-hop-type VnetLocal --resource-group $resourceGroup --route-table-name $route

echo "Configuring $subnet with $nsg and $route..."
az network vnet subnet update --name $subnet --network-security-group $nsg --route-table $route --vnet-name $vNet --resource-group $resourceGroup 

```

Once the Network deploys the resources for SQL Managed Instance it should look like this: 

![ContosoAzureEastUSsqlmiVNetTest3](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/ContosoAzureEastUSsqlmiVNetTest3rg.png)


### DatabaseAdmin provides a CLI script to the EngineeringOps to create SQL MI instance in the SQL MI instance Resource group

Use a Azure CLI script [4-CreateSQLMIinstance.sh](https://github.com/DataSnowman/sqlmideployment/blob/main/scripts/cli/4-CreateSQLMIinstance.sh) or (PowerShell, portal, etc.) 

NOTE THIS SCRIPT NEEDS SOME WORK but works in CLI cut and pasted into CMD (It does not work as a bash shell currently)

```
az sql mi create -g DevContosoAzureEastUSsqlmiTest3 -n sqlmitest3 -l eastus -i -u adminuser -p Astr0ng15charP@ssword --license-type BasePrice --subnet /subscriptions/<subscriptionIDHere>/resourceGroups/ContosoAzureEastUSsqlmiVNetTest3/providers/Microsoft.Network/virtualNetworks/ContosoAzureEastUSsqlmiVNetTest3/subnets/DevelopmentSQLMIsubnetTest3 --capacity 4 --storage 32GB --edition GeneralPurpose --family Gen5 --tags Environment=DevelopmentSQLMI
```

The SQL MI deployment should create a Virtual Cluster in the SQL MI vNet Resource group (i.e. ContosoAzureEastUSsqlmiVNetTest3) 

`Note: the Virtual Cluster is only viewable by higher permissioned users and neither the “SQL Managed Instance Contributor” nor “Network Contributor” can see the Virtual Cluster`

![virtualCluster](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/virtualCluster.png)

The SQL MI instance Resource group (i.e. DevContosoAzureEastUSsqlmiTest3) should look like this:

![sqlMIinstance](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/sqlMIinstance.png)

Note that given the role assignments provided above, the Azure Portal can also be used to deploy a SQL MI instance

![basicsPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/basicsPortal.png)

![networkingPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/networkingPortal.png)

![securityPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/securityPortal.png)

![additionalPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/additionalPortal.png)

![tagsPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/tagsPortal.png)

![reviewcreatePortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/reviewcreatePortal.png)


`Note deploying via the portal creates the same Virutal Cluster`

![virtualClusterPortal](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/virtualClusterPortal.png)


### Configure a Private Endpoint in the Azure SQL Managed Instance

Here are a couple of links on configuring a Private Endpoint in the Azure SQL Managed Instance

[Configuring Private Endpoint Connections in Azure SQL Managed Instance](https://techcommunity.microsoft.com/t5/azure-database-support-blog/lesson-learned-238-configuring-private-endpoint-connections-in/ba-p/3635128)

[Azure Private Link for Azure SQL Managed Instance (Preview)](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/private-endpoint-overview?view=azuresql&tabs=separate-vnets)

EngineeringOpsAdmin Creates Resource group for SQL MI vNet for a Private endpoint (if not already exists) Something like ContosoAzureEastUSsqlmiVNetTest4ForPrivateEndpoint and a second RG for the private endpoint like ContosoAzureEastUSsqlmiTest4PrivateEndpoint

EngineeringOpsAdmin adds a role assignment of "Network Contributor" in the SQL MI vNet for a Private Endpoint Resource group (i.e. ContosoAzureEastUSsqlmiVNetTest4ForPrivateEndpoint) and selects the NetworkAdmin user performing the vNet deployment. 

EngineeringOpsAdmin adds a role assignment of "SQL Managed Instance Contributor" in the SQL MI vNet for a Private Endpoint Resource group (i.e. ContosoAzureEastUSsqlmiVNetTest4ForPrivateEndpoint) and selects the EngineeringOps user performing the Private endpoint deployment. 

EngineeringOpsAdmin also adds a role assignment of "SQL Managed Instance Contributor" to the RG for the Private endpoint (i.e.ContosoAzureEastUSsqlmiTest4PrivateEndpoint) and selects the EngineeringOps user performing the Private endpoint deployment.  

The NetworkAdmin deploys a vNet into the assigned RG

![privateEndpointvNet](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/privateEndpointvNet.png)

The EngineeringOps user deploys a private endpoint into the assigned RG

In the SQL MI instance choose Private endpoint connections and click + Private endpoint

![connectionsPrivateEndpointt](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/connectionsPrivateEndpoint.png)

![basicsPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/basicsPrivateEndpoint.png)

The resource is autopopulated

![resourcePrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/resourcePrivateEndpoint.png)

Choose the vNet and subnet created by the Network Admin

![vNetPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/vNetPrivateEndpoint.png)

As you could see the DNS configuration is disabled for Managed Instance and we are going to configure it later

![dnsPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/dnsPrivateEndpoint.png)

Finish with any tags and click on Next: Review + create

With the "SQL Managed Instance Contributor" permissions I get this error:

![createErrorPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/createErrorPrivateEndpoint.png)

When I run the same create private enpoint with a higher privelege user there is a Target Sub-resource item on the Resource section.  The error could step from this

![resourceTargetSub-resourcePrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/resourceTargetSub-resourcePrivateEndpoint.png)

The Virtual Network also has a Name and Private IP attribute that is not in the portal with "SQL Managed Instance Contributor" permission but is with higher privelege user

![vNetPrivateStaticIPprivateIPEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/vNetPrivateStaticIPprivateIPEndpoint.png)


Here is what it should look like with higher permisssions (to be determined)

![highbasicsPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/highbasicsPrivateEndpoint.png)

The resource is autopopulated

![highresourcePrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/highresourcePrivateEndpoint.png)

Choose the vNet and subnet created by the Network Admin

![highvNetPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/highvNetPrivateEndpoint.png)

As you could see the DNS configuration is disabled for Managed Instance and we are going to configure it later

![highdnsPrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/highdnsPrivateEndpoint.png)

Finish with any tags and click on Next: Review + create

This time it works.  Click Create

![highcreatePrivateEndpoint](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/highcreatePrivateEndpoint.png)

Here are the resources that are deployed

![privateEndpointResources](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/privateEndpointResources.png)

[Review and approve a request to create a private endpoint](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/private-endpoint-overview?view=azuresql&tabs=same-vnet#review-and-approve-a-request-to-create-a-private-endpoint)

Mine was auto-approved based on the user I used

[Set up domain name resolution for private endpoint](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/private-endpoint-overview?view=azuresql&tabs=same-vnet#set-up-domain-name-resolution-for-private-endpoint)




## fix from here

[Create an Azure SQL Managed Instance with a user-assigned managed identity](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/authentication-azure-ad-user-assigned-managed-identity-create-managed-instance?view=azuresql&tabs=azure-cli)


### Create a CNAME Record in your DNS using Private Endpoint static IP

`Note not necessary step if you are using Azure DNS`

If you have a custom DNS maintained in a product like Infoblox you will need to use the Private Endpoint created above to create a CNAME record with a static IP.

### To avoid needing a Global Admin from always enabling the creation of a 

![aadadmin](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/aadadmin.png)

`To be updated, enhanced, and validated in coming weeks`

### AADAdmin Creates a Managed Identity – see: 
a.	[Manage user-assigned managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp)

Create a user-assigned managed identity in a Resource group

![uami](https://raw.githubusercontent.com/DataSnowman/sqlmideployment/main/images/managedidentity.png)