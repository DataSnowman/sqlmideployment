#!/bin/bash

# Create an Azure SQL Managed Instance virtual network

# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="eastus"
resourceGroup="DevContosoAzureEastUSsqlmiTest2"
vNet="ContosoAzureEastUSsqlmiVNetTest2"
subnet="DevelopmentSQLMIsubnetTest2"
instance="sqlmitest2"
login="adminuser"
password="Astr0ng15charP@ssword"

echo "Using resource group $resourceGroup with login: $login, password: $password..."

#echo "Creating $resourceGroup in $location..."
az group create --name $resourceGroup --location "$location" --tags $tag 

#echo "Creating $instance with $subnet..."

# This step will take awhile to complete. You can monitor deployment progress in the activity log within the Azure portal.

# Syntax to create an Azure SQL Managed Instance with a user-assigned managed identity
# az sql mi create --assign-identity --identity-type UserAssigned --user-assigned-identity-id /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<managedIdentity> --primary-user-assigned-identity-id /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<primaryIdentity> --enable-ad-only-auth --external-admin-principal-type User --external-admin-name <AzureADAccount> --external-admin-sid <AzureADAccountSID> -g <ResourceGroupName> -n <managedinstancename> --subnet /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.Network/virtualNetworks/<VNetName>/subnets/<SubnetName>

az sql mi create -g DevContosoAzureEastUSsqlmi -n sqlmidev4 -l eastus -i -u adminuser -p Astr0ng15charP@ssword --license-type BasePrice --subnet /subscriptions/<subscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.Network/virtualNetworks/<virtualnetwork>/subnets/<subnets> --capacity 4 --storage 32GB --edition GeneralPurpose --family Gen5 --tags Environment=DevelopmentSQLMI

# NOTE THIS SCRIPT NEEDS SOME WORK
