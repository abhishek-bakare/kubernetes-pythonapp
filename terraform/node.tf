

################################################
# node role
################################################

resource "aws_iam_role" "eksNodeRole" {
    name = var.node_role
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
    })
  
}

##############################################
# policy attachment
##############################################

resource "aws_iam_role_policy_attachment" "eksWorkerNodePolicy" {

    role = aws_iam_role.eksNodeRole.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    depends_on = [ aws_iam_role.eksNodeRole ]

}

resource "aws_iam_role_policy_attachment" "eksWorkerCNIPolicy" {

    role = aws_iam_role.eksNodeRole.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    depends_on = [ aws_iam_role.eksNodeRole ]
  
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {

    role = aws_iam_role.eksNodeRole.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    depends_on = [ aws_iam_role.eksNodeRole ]
  
}

resource "aws_iam_role_policy_attachment" "node_instance_role_ssm" {

    role = aws_iam_role.eksNodeRole.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    depends_on = [ aws_iam_role.eksNodeRole ]
  
}

#############################################
# ami for eks nodes
#############################################

data "aws_ssm_parameter" "eks_ami" {

    name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id"
  
}

################################################
# node group
################################################

resource "aws_launch_template" "eks_nodes" {

    name = "${var.cluster_name}-node"
    image_id = data.aws_ssm_parameter.eks_ami.value
    instance_type = "t3.medium"
    # creating keypair is immortant ypu can create first KP manually using console or CLI and mention here the name it is the recommended way
    key_name = "kp"  
    vpc_security_group_ids = [aws_eks_cluster.demoeks.vpc_config[0].cluster_security_group_id]  
    iam_instance_profile {
        name = aws_iam_role.eksNodeRole.id
    }
    user_data = base64encode(<<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.cluster_name}
    EOF
    ) 
    tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }
}

################################################
# autoscaling groups
################################################

resource "aws_autoscaling_group" "eks_autoscaling" {

    name = "${var.cluster_name}-node"
    desired_capacity = 2
    max_size = 3
    min_size = 1
    target_group_arns = []
    vpc_zone_identifier = [ module.vpc.subnet_id1, module.vpc.subnet_id2, module.vpc.subnet_id3 ]

    launch_template {
      id = aws_launch_template.eks_nodes.id
      version = "$Latest"
    }

    tag {
        key = "kubernetes.io/cluster/${var.cluster_name}"
        value = "owned"
        propagate_at_launch = true
    }
  
}
