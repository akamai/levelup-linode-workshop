terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}
//Use the Linode Provider
provider "linode" {
  token = var.token
}

//Use the linode_lke_cluster resource to create
//a Kubernetes cluster
resource "linode_lke_cluster" "foobar" {
    k8s_version = var.k8s_version
    label = "lke-west"
    region = "us-west"
    tags = var.tags

    dynamic "pool" {
        for_each = var.pools
        content {
            type  = pool.value["type"]
            count = pool.value["count"]
        }
    }
}
resource "local_file" "lke_kubeconfig_yaml" {
    content  = base64decode(linode_lke_cluster.thecluster.kubeconfig)
    filename = "${path.module}/kubeconfig.yaml"
}
//Export this cluster's attributes
output "kubeconfig" {
   value = linode_lke_cluster.foobar.kubeconfig
   sensitive = true
}
output "api_endpoints" {
   value = linode_lke_cluster.foobar.api_endpoints
}

output "status" {
   value = linode_lke_cluster.foobar.status
}

output "id" {
   value = linode_lke_cluster.foobar.id
}

output "pool" {
   value = linode_lke_cluster.foobar.pool
}
    
