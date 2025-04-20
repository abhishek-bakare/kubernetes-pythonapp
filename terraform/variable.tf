variable "cluster_name" {

    description = "The name of the cluster"
    type        = string
  
}

variable "endpoint_public_access" {

    description = "Whether to enable private access to the cluster endpoint"
    type        = bool
  
}

variable "endpoint_private_access" {
    
    description = "Whether to enable private access to the cluster endpoint"
    type        = bool
  
}

variable "cluster_role" {

    description = "The name of the cluster role"
    type        = string
  
}

variable "node_role" {

    description = "The name of the node role"
    type = string
  
}