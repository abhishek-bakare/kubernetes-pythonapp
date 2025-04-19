variable "cluster_name" {

    description = "The name of the cluster"
    type        = string
    default     = "my-eks"
  
}

variable "endpoint_public_access" {

    description = "Whether to enable private access to the cluster endpoint"
    type        = bool
    default     = true
  
}

variable "endpoint_private_access" {
    
    description = "Whether to enable private access to the cluster endpoint"
    type        = bool
    default     = false
  
}

variable "cluster_role" {

    description = "The name of the cluster role"
    type        = string
    default     = "eksClusterRole"
  
}

variable "node_role" {

    description = "The name of the node role"
    type = string
    default = "eksNodeRole"
  
}