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

#-- Apply some changes later: kubectl apply -f FILENAME
kubectl apply -f sqlserver.yml
kubectl apply -f sqlserver1866LB.yml

#--  check if all components created and running
#-- verify that container created
kubectl get pods
#Verify if SQl is running by accessing it's startup log. Check Prot #.
kubectl logs sqlserver1234_from_pod
#-- check deployments
kubectl get deployments
#-- Check the sql service
kubectl get service
#-- if all looks good use ExternalIP for SQL service to connect from any SQL vm or app in azure or public network. : 
# for example use Iot Dev SQL vm and use my sql login to connect


#-- Gracefully stop resources like pods, services 
# kubectl stop pods,services -l name=myLabel
# UGH Deprecated -- kubectl stop services -l name=sqlserver-servces
#------------------------------------
kubectl get pods
#-- Delete pod and see if AKS willtry to recover SQL service on a new pod
kubectl delete pod mssql-deployment-0
kubectl get pods

#-- The better way to configure DR SQL in AKS is to provision persistent storage. 
#-- How to create persistent storage and use it with SQL container in aks:
#-- https://docs.microsoft.com/en-us/sql/linux/tutorial-sql-server-containers-kubernetes
#--
#-- Also look at how to store secured PWD in AKS


#------------------------------------
#--  Cleanup 
#------------------------------------

kubectl delete deployment sqlserver
kubectl get service
kubectl delete service sqlserver-service

 
#------------------------------------
#--  Cleanup Nuke option
#------------------------------------
kubectl delete deployment --namespace=kube-system --all
kubectl get deployment --namespace=kube-system

kubectl delete nodes --all
kubectl get nodes 

#-- Nuke option - delete whole AKS or even  RG
#az group delete --name vr-aks-rg01 

#-- Delete AKS cluster
az aks delete --resource-group vr-aks-rg01 --name vr-aks-cluster01


