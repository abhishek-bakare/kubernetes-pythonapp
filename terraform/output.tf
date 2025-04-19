output "cluster_endpoint" {

    description = "The endpoint of the EKS cluster"
    value       = aws_eks_cluster.demoeks.endpoint
  
}

output "cluster_security_group_id" {

    description = "The security group of the EKS cluster"
    value       = aws_eks_cluster.demoeks.vpc_config[0].cluster_security_group_id
  
}

output "cluster_iam_role_name" {

    description = "The IAM role of the EKS cluster"
    value       = aws_iam_role.eksClusterRole.arn
  
}

output "node-group_name" {

    description = "Name of the eks node group"
    value = aws_autoscaling_group.eks_autoscaling.name
  
}

output "node_role_arn" {

    description = "The IAM role of the EKS cluster"
    value       = aws_iam_role.eksNodeRole.arn
  
}