####################################################
# module vpc
####################################################

module "vpc" {

    source = "./modules/vpc"
    #vpc_name = "eks-vpc_mine"
  
}

#####################################################
# EKS Cluster
#####################################################

resource "aws_eks_cluster" "demoeks" {

    name = var.cluster_name
    role_arn = aws_iam_role.eksClusterRole.arn

    vpc_config {
      subnet_ids = [ module.vpc.aws_subnet.eks_vpc_public_subnet1.id, module.vpc.aws_subnet.eks_vpc_public_subnet2.id, module.vpc.aws_subnet.eks_vpc_public_subnet3.id ]
      #security_group_ids = [aws_security_group.eks_vpc_public_sg.id]
      endpoint_public_access = var.endpoint_public_access
      endpoint_private_access = var.endpoint_private_access
    }
    depends_on = [ module.vpc ]
  
}


#######################################################
# EKS Cluster IAM Role
#######################################################

resource "aws_iam_role" "eksClusterRole" {

    name = var.cluster_role
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
    })
    tags = {
        Name = "${var.cluster_name}"
        Terraform = "true"
    }
  
}

#######################################################
# EKS Cluster IAM Role Policy Attachment
#######################################################

resource "aws_iam_role_policy_attachment" "eksClusterPolicy" {

    role       = aws_iam_role.eksClusterRole.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    depends_on = [aws_iam_role.eksClusterRole]
  
}


