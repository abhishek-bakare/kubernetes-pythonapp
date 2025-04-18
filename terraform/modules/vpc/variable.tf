variable "region" {

    description = "The AWS region to create resources in"
    type        = string
    default     = "us-east-1"
  
}

variable "vpc_cidr_block" {

    description = "CIDR for VPC"
    type        = string
    default     = "192.168.0.0/16"
  
}

variable "vpc_name" {

    description = "The name of the VPC"
    type        = string
    default     = "eks-vpc"
  
}

variable "vpc_env" {

    description = "The environment for the VPC"
    type        = string
    default     = "dev"
  
}

variable "eks_vpc_public_cidr1" {

    description = "CIDR for public subnet"
    type        = string
    default     = "192.168.1.0/24"
  
}

variable "az1" {

    description = "Availability zone for public subnet 1"
    type        = string
    default     = "us-east-1a"
  
}

variable "eks_vpc_public_cidr2" {

    description = "CIDR for public subnet 2"
    type        = string
    default     = "192.168.2.0/24"
  
}

variable "az2" {

    description = "Availability zone for public subnet 2"
    type        = string
    default     = "us-east-1b"
  
}

variable "eks_vpc_public_cidr3" {

    description = "CIDR for public subnet 2"
    type        = string
    default     = "192.168.3.0/24"
  
}

variable "az3" {

    description = "Availability zone for public subnet 2"
    type        = string
    default     = "us-east-1c"
  
}

