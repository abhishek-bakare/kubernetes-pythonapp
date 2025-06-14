output "vpc_id" {
    
    value = aws_vpc.eks_vpc.id
    description = "The ID of the VPC"
  
}

output "subnet_id1" {

        
    value = aws_subnet.eks_vpc_public_subnet1.id
    description = "The ID of the first public subnet"
  
}

output "subnet_id2" {

        
    value = aws_subnet.eks_vpc_public_subnet2.id
    description = "The ID of the second public subnet"
  
}

output "subnet_id3" {

        
    value = aws_subnet.eks_vpc_public_subnet3.id
    description = "The ID of the third public subnet"
  
}

output "security_grps" {

    value = aws_security_group.eks_vpc_public_sg.id
    description = "The ID of security grps"
  
}