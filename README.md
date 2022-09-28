Linode LevelUp Workshop
======================

# About

Package of template files, examples, and illustrations for the Linode Level Up Workshop Exercise.

# Contents

## Template Files
- Sample Terraform files for deploying an LKE cluster on Linode.
- Sample kubernetes deployment files for starting an application on an LKE cluster.

### Exercise Diagram
![Levelup Linode Diagram- Cox Auto -3](https://user-images.githubusercontent.com/19197357/192828729-e87a7a6e-e410-42b7-a060-b7158fb2ba85.jpg)

## Step by Step Instructions

### Overview

The scenario is written to approximate deployment of a resillient, node-based API endpoint, that can provide both synchronous (via HTTP) and async (via a variety of pub/sub protocols) services to end users.

The workshop scenario builds the following components and steps-

1. A Secure Shell Linode (provisioned via the Linode Cloud Manager GUI) to serve as the command console for the environment setup.

2. Installing developer tools on the Secure Shell (git, terraform, and kubectl) for use in envinroment setup.

3. A Linode Kubernetes Engine (LKE) Cluster, provisioned via terraform.

4. Deploying a Node container to the cluster, and exposing an HTTP service from this deployment mapped to the node API endpoint. 


### Build a Secure Shell Linode
![shell](https://user-images.githubusercontent.com/19197357/184126449-454162f9-142f-47e6-ab73-3f1da5e5f456.png)

We'll first create a Linode using the "Secure Your Server" Marketplace image. This will give us a hardened, consistent environment to run our subsequent commands from. 

1. Create a Linode user
 - Go to the URL given to you during the session, enter a desired username (must be unique) and email, and verify/set your password when the link arrives in your inbox.
2. Login to Linode Cloud Manager
 - https://login.linode.com/login
3. Select "Create Linode"
4. Select "Marketplace"
5. Click the "Secure Your Server" Marketplace image. 
6. Scroll down and complete the following steps:
 - Limited sudo user
 - Sudo password
 - Ssh key
 - No Advanced options are required

7. Select the Debian 11 image type for Select an Image
8. Select a Region.
9. Select the Shared CPU 1GB "Nanode" plan.
10. Enter a root password.
11. Click Create Linode.

12. Once your Linode is running, login to it's shell (either using the web-based LISH console from Linode Cloud Manager, or via your SSH client of choice).

### Install and Run git 

Next step is to install git, and pull this repository to the Secure Shell Linode. The repository includes terraform and kubernetes configuration files that we'll need for subsequent steps.

1. Install git via the SSH or LISH shell-

```
sudo apt-get -y install git
```
2. Pull down this repository to the Linode machine-

```
git init && git pull https://github.com/akamai/levelup-linode-workshop
```

### Install Terraform 

Next step is to install Terraform. The repository files include a terraform.sh script that perform the needed shell commands to install Terraform.

1. Run the terraform.sh script-
```
./terraform.sh
```

### Provision LKE Cluster using Terraform
![tf](https://user-images.githubusercontent.com/19197357/184130473-91c36dfc-072b-43f7-882b-07407d7f2266.png)

Next, we build the LKE cluster, with the terraform files that are included in this repository, and pulled into the Linode Shell from the prior git command.

1. From the Linode Cloud Manager, create an API token and copy it's value (NOTE- the Token should have full read-write access to all Linode components in order to work properly with terraform).
 - Click on your user name at the top right of the screen
 - Select API Tokens
 - Click Create a Personal Access Token
 - Be sure to copy and save the token value


2. From the Linode shell, set the TF_VAR_token env variable to the API token value. This will allow terraform to use the Linode API for infrastructure provisioning.
```
export TF_VAR_token=[api token value]
```
3. Initialize the Linode terraform provider-
```
terraform init 
```
4. Next, we'll use the supplied terraform files to provision the LKE clusters. First, run the "terraform plan" command to view the plan prior to deployment-
```
terraform plan \
 -var-file="terraform.tfvars"
 ```
 5. Run "terraform apply" to deploy the plan to Linode and build your LKE clusters-
 ```
 terraform apply \
 -var-file="terraform.tfvars"
 ```
Once deployment is complete, you should see a LKE clusters within the "Kubernetes" section of your Linode Cloud Manager account.

### Deploy Containers to LKE 
![k8](https://user-images.githubusercontent.com/19197357/184130510-08d983b6-109c-4bdb-b50c-db97fec3571d.png)

Next step is to use kubectl to deploy the container endpoints to the LKE cluster. The repository includes a script to perform the needed steps to install kubectl-

1. Install kubectl by running the kubectl-install script included in the repository-
```
./kubectl-install.sh
```
2. Define the yaml file output from the prior step as the kubeconfig.
```
export KUBECONFIG=kubeconfig.yaml
```
3. You can now use kubectl to manage the LKE cluster. Enter the below command to view a list of clusters, and view which cluster is currently being managed.
```
kubectl config get-contexts
```
4. Deploy an application to the the LKE cluster, using the deployment.yaml file included in this repository.
```
kubectl create -f deployment.yaml
```
5. Next, we need to set our certificate and private key values as kubeconfig secrets. This will allow us to enable TLS on our LKE cluster. 

NOTE: For ease of the workshop, the certificate and key are included in the repository. This is not a recommended practice.
```
kubectl create secret tls mqtttest --cert cert.pem --key key.pem
```
6. Deploy the service.yaml included in the repository via kubectl to allow inbound traffic.
```
kubectl create -f service.yaml
```
7. Validate that the service is running, and obtain it's external IP address.
```
kubectl get services -A
```
This command output should show a node-api deployment, with an external (Internet-routable, non-RFC1918) IP address. Make note of this external IP address as it represents the ingress point to your cluster application.

### Summary of Linode Provisioning 

With the work above done, you've successfully setup a kubernetes cluster in a linode region, and deployed an endpoint application to it. 


