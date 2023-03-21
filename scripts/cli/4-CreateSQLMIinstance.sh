#!/bin/bash

# Create an Azure SQL Managed Instance virtual network

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="eastus"
resourceGroup="DevContosoAzureEastUSsqlmiTest3"
networkrg="ContosoAzureEastUSsqlmiVNetTest3"
vNet="ContosoAzureEastUSsqlmiVNetTest3"
subnet="DevelopmentSQLMIsubnetTest3"
instance="sqlmitest3"
login="adminuser"
password="Astr0ng15charP@ssword"
subscriptionId="<subscriptionId>"


echo "Using resource group $resourceGroup with login: $login, password: $password..."

#echo "Creating $resourceGroup in $location..."
#az group create --name $resourceGroup --location "$location" --tags $tag 

#echo "Creating $instance with $subnet..."

# This step will take awhile to complete. You can monitor deployment progress in the activity log within the Azure portal.

# Syntax to create an Azure SQL Managed Instance with a user-assigned managed identity
# az sql mi create --assign-identity --identity-type UserAssigned --user-assigned-identity-id /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<managedIdentity> --primary-user-assigned-identity-id /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<primaryIdentity> --enable-ad-only-auth --external-admin-principal-type User --external-admin-name <AzureADAccount> --external-admin-sid <AzureADAccountSID> -g <ResourceGroupName> -n <managedinstancename> --subnet /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.Network/virtualNetworks/<VNetName>/subnets/<SubnetName>

#az sql mi create -g $resourceGroup -n $instance -l $location -i -u $login -p $password --license-type BasePrice --subnet /subscriptions/$subscriptionId/resourceGroups/$networkrg/providers/Microsoft.Network/virtualNetworks/$vNet/subnets/$subnet --capacity 4 --storage 32GB --edition GeneralPurpose --family Gen5 --tags Environment=DevelopmentSQLMI

# NOTE THIS SCRIPT NEEDS SOME WORK but works in CLI cut and pasted into CMD (Does not work as a bash shell)

az sql mi create -g DevContosoAzureEastUSsqlmiTest3 -n sqlmitest3 -l eastus -i -u adminuser -p Astr0ng15charP@ssword --license-type BasePrice --subnet /subscriptions/<subscriptionId>/resourceGroups/ContosoAzureEastUSsqlmiVNetTest3/providers/Microsoft.Network/virtualNetworks/ContosoAzureEastUSsqlmiVNetTest3/subnets/DevelopmentSQLMIsubnetTest3 --capacity 4 --storage 32GB --edition GeneralPurpose --family Gen5 --tags Environment=DevelopmentSQLMI
