################################################
# creating a VPC for EKS cluster
################################################

resource "aws_vpc" "eks_vpc" {

    cidr_block = var.vpc_cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}-vpc"
        Environment = var.vpc_env
        Terraform = "true"
    }
  
}

##################################################
# creating IGW for VPC
##################################################

resource "aws_internet_gateway" "eks_vpc_igw" {

    vpc_id = aws_vpc.eks_vpc.id
    tags = {
        Name = "${var.vpc_name}-igw"
        Environment = var.vpc_env
        Terraform = "true"
    }
  
}

##################################################
# creating public subnets for VPC
##################################################

resource "aws_subnet" "eks_vpc_public_subnet1" {

    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.eks_vpc_public_cidr1
    availability_zone = var.az1
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.vpc_name}-public-subnet1"
        Environment = var.vpc_env
        Terraform = "true"
    }
}

resource "aws_subnet" "eks_vpc_public_subnet2" {

    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.eks_vpc_public_cidr2
    availability_zone = var.az2
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.vpc_name}-public-subnet2"
        Environment = var.vpc_env
        Terraform = "true"
    }
  
}

resource "aws_subnet" "eks_vpc_public_subnet3" {

    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.eks_vpc_public_cidr3
    availability_zone = var.az3
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.vpc_name}-public-subnet3"
        Environment = var.vpc_env
        Terraform = "true"
    }
  
}

##################################################
# route table for public subnets
##################################################

resource "aws_route_table" "eks_vpc_public_route_table" {

    vpc_id = aws_vpc.eks_vpc.id
    tags = {
        Name = "${var.vpc_name}-public-route-table"
        Environment = var.vpc_env
        Terraform = "true"
    }
  
}

resource "aws-route" "eks_vpc_public_route" {

    route_table_id = aws_route_table.eks_vpc_public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_igw.id
    depends_on = [aws_internet_gateway.eks_vpc_igw] 
    tags = {
        Name = "${var.vpc_name}-public-route"
        Environment = var.vpc_env
        Terraform = "true"
    }
}

###################################################
# associating public subnets with route table
###################################################

resource "aws_route_table_association" "eks_vpc_public_subnet1_association" {

    subnet_id = aws_subnet.eks_vpc_public_subnet1.id
    route_table_id = aws_route_table.eks_vpc_public_route_table.id
    depends_on = [aws_route_table.eks_vpc_public_route_table] 
  
}

resource "aws_route_table_association" "eks_vpc_public_subnet2_association" {

    subnet_id = aws_subnet.eks_vpc_public_subnet2.id
    route_table_id = aws_route_table.eks_vpc_public_route_table.id
    depends_on = [aws_route_table.eks_vpc_public_route_table] 
  
}

resource "aws_route_table_association" "eks_vpc_public_subnet3_association" {

    subnet_id = aws_subnet.eks_vpc_public_subnet3.id
    route_table_id = aws_route_table.eks_vpc_public_route_table.id
    depends_on = [aws_route_table.eks_vpc_public_route_table] 
  
}

###################################################
# creating security group for public subnets
###################################################

resource "aws_security_group" "eks_vpc_public_sg" {

    vpc_id = aws_vpc.eks_vpc.id
    name = "${var.vpc_name}-public-sg"
    description = "Security group for public subnets"
    tags = {
        Name = "${var.vpc_name}-public-sg"
        Environment = var.vpc_env
        Terraform = "true"
    }

    # basic rules are added for HTTP, HTTPS and SSH access
    # for the public subnets. You can add more rules as per your requirements.
    # we will add more rules from console which is required for this application.
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP"
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }

}