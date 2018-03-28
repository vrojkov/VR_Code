# Based on AKS cluster vr-aks-cluster01 is already created - ref script AKS-setup_sript
# az aks create --resource-group vr-aks-rg01 --name vr-aks-cluster01 --kubernetes-version 1.8.7 --node-count 1 --generate-ssh-keys

#We will be working with Azure CLI so do this to install CLI if needed:
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
     sudo tee /etc/apt/sources.list.d/azure-cli.list
      
      
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

#Check CLI version 
az --version

#Login to Azure
az Login

#Check if the container provide r registered.  To register :  az provider register -n Microsoft.ContainerService
az provider show -n Microsoft.ContainerService

#----------------------------------------------------------------------------------------------------
#Now real session to  add SQL once all prereqs installed 
#----------------------------------------------------------------------------------------------------
az aks get-credentials --resource-group vr-aks-rg01 --name vr-aks-cluster01

#Ceck nodes
kubectl get nodes

#Get SQL config info from sqlserver.yml and copy it into AKS
nano sqlserver.yml

#-- !!! Time to create SQL -------
kubectl create -f sqlserver.yml

#--  check if all components created and running
#-- verify that container created
kubectl get pods
#-- check deployments
kubectl get deployments
#-- Check the sql service
kubectl get service
#-- iff all looks good use ExternalIP for SQL service to connect from any SQL vm or app in azure or public network. : 



