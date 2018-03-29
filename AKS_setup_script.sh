docker run -ti docker4x/create-sp-azure sp-VRSQL vr-azure-docker-rg01 Eastern


openssl.exe req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout VRAksPrivateKey.key -out VRAksCert.pem


openssl.exe rsa -pubout -in VRAksPrivateKey.key -out VRAksPublicKey.key


-- Set AKS via Azure shell
1. in browser open(pick bash or powershell): 
	shell.azure.com 
2. Enable AKS:
az provider register -n Microsoft.ContainerService

3. Creat enew RG
az group create --name vr-aks-rg01 --location eastus

4. Create new AKS cluster
az aks create --name vr-aks-cluster01 --resource-group vr-aks-rg01 --kubernetes-version 1.8.7 --node-count 1 --generate-ssh-keys --no-wait

If failed then :
Check if SSH careated
ls ~/.ssh/ 
Try to recreate cluster with existing key:
az aks create --name vr-aks-cluster01 --resource-group vr-aks-rg01 --kubernetes-version 1.8.7 --node-count 1 --ssh-key-value ~/.ssh/id_rsa.pub --no-wait


5.  configure kubectl to connect to your Kubernetes cluster, run the following command. This step downloads credentials and configures the Kubernetes CLI to use them.
az aks get-credentials --name vr-aks-cluster01 --resource-group vr-aks-rg01



6. Verify :
kubectl get nodes

Check if container service registered
az provider show -n Microsoft.ContainerService

Check cluster version:
az aks get-versions -l <LOCATION>

Upgarecluster to new version
az aks upgrade -n vr-aks-cluster01 -g vr-aks-rg01  -k 1.8.2  # --debug


50. Scale AKS cluster
az aks scale  --name vr-aks-cluster01 --resource-group vr-aks-rg01 --node-count 3
az aks scale  --name vr-aks-cluster01 --resource-group vr-aks-rg01 --node-count 1


60. Upgrade AKS cluster
60.1 Show available AKS versions
az aks get-upgrades --name vr-aks-cluster01 --resource-group vr-aks-rg01 --output table
60.2 Upgarade cluster to ver 1.8.7 ( based on list from 60.1 )
az aks upgrade --name vr-aks-cluster01 --resource-group vr-aks-rg01  --kubernetes-version 1.8.7

99. Delete AKS cluster
az group delete --name vr-aks-rg01 --no-wait --yes 