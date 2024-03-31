# 02-state-storage
$REGION='AustraliaEast'
$STORAGEACCOUNTNAME='stgauaeadevtfstate'
$CONTAINERNAME='akscs'
$TFSTATE_RG='rg-auea-dev-tfstate'
$tf = "C:\tools\terraform\terraform.exe"
az group create --name $TFSTATE_RG --location $REGION

az storage account create -n $STORAGEACCOUNTNAME -g $TFSTATE_RG -l $REGION --sku Standard_LRS 

az storage container-rm create --storage-account $STORAGEACCOUNTNAME --name $CONTAINERNAME

Set-Alias -Name tf -Value $tf

# 03-eid
cd .\03-EID-create


tf init -backend-config="resource_group_name=$TFSTATE_RG" `
    -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME" -reconfigure

tf plan

tf apply

# N/A, fails with 400 BadRequest
<#
╷
│ Error: Creating group "AKS App Admin Team 01357"
│
│   with azuread_group.appdevs,
│   on ad_groups.tf line 5, in resource "azuread_group" "appdevs":
│    5: resource "azuread_group" "appdevs" {
│
│ GroupsClient.BaseClient.Post(): unexpected status 400 with OData error: Request_BadRequest: Request contains a property with duplicate values.
╵
╷
│ Error: Creating group "AKS App Dev Team 01357"
│
│   with azuread_group.aksops,
│   on ad_groups.tf line 10, in resource "azuread_group" "aksops":
│   10: resource "azuread_group" "aksops" {
│
│ GroupsClient.BaseClient.Post(): unexpected status 400 with OData error: Request_BadRequest: Request contains a property with duplicate values.
╵
#>
cd ..

# 04-Network-Hub
cd .\04-Network-Hub

tf init -backend-config="resource_group_name=$TFSTATE_RG" `
    -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

tf plan

tf apply -var admin_password="***"

cd ..

# 05-Network-Spoke
cd ./05-Network-LZ

tf init -backend-config="resource_group_name=$TFSTATE_RG" `
    -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

tf plan

tf apply

cd..

# 06-AKS-supporting
cd ./06-AKS-supporting

tf init -backend-config="resource_group_name=$TFSTATE_RG" `
    -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

tf plan

tf apply

cd ..

# 07-AKS-Cluster
cd ./07-AKS-Cluster

tf init -backend-config="resource_group_name=$TFSTATE_RG" `
    -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

tf plan

tf apply

cd ..

