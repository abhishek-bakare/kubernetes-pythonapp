################################################
# node role
################################################
data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#arn:aws:iam::730335390054:role/eksNodeRole

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

    name = "/aws/service/eks/optimized-ami/1.24/amazon-linux-2/recommended/image_id"
  
}

################################################
# node group
################################################

resource "aws_iam_instance_profile" "node_instance_profile" {
    name = "NodeInstanceProfile"
    path = "/"
    role = aws_iam_role.eksNodeRole.id
}

################################################
# defining cluster endpoint & cert auth
################################################

locals {
  cluster_endpoint = aws_eks_cluster.demoeks.endpoint
  cluster_cert_auth = aws_eks_cluster.demoeks.certificate_authority[0].data
}

################################################
# lauch template
################################################

resource "aws_launch_template" "eks_nodes" {

    name = "${var.cluster_name}-node"
    image_id = data.aws_ssm_parameter.eks_ami.value
    instance_type = "t3.medium"
    # creating keypair is important ypu can create first KP manually using console or CLI and mention here the name it is the recommended way
    key_name = "kp"  
    vpc_security_group_ids = [aws_eks_cluster.demoeks.vpc_config[0].cluster_security_group_id]  
    iam_instance_profile {
        name = aws_iam_instance_profile.node_instance_profile.name
    }
    #network_interfaces {
    #security_groups = [aws_security_group.eks_node_sg.id] # Use the security group created below
    #associate_public_ip_address = true
    #}
    user_data = base64encode(<<-EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.cluster_name} \
      --apiserver-endpoint ${local.cluster_endpoint} \
      --b64-cluster-ca ${local.cluster_cert_auth}
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

################################################
# required eks token for K8 configmap
################################################

data "aws_eks_cluster_auth" "eks_token" {

  name = var.cluster_name
  
}

################################################
# K8 provider defination
################################################

provider "kubernetes" {

  host = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_cert_auth)
  token = data.aws_eks_cluster_auth.eks_token.token
  
}


################################################
# adding eks cluster to local 
################################################

resource "null_resource" "eks_to_local" {

  provisioner "local-exec" {

    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region us-east-1"
    
  }

  depends_on = [ aws_eks_cluster.demoeks ]
  
}


################################################
# aws-auth configmap 
################################################

resource "kubernetes_config_map" "aws_auth" {

  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = yamlencode([
      {
        rolearn  = aws_iam_role.eksNodeRole.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
    ])
  }

  depends_on = [ aws_autoscaling_group.eks_autoscaling, null_resource.eks_to_local ]
  
}

################################################
# checking nodes are joined or not
################################################

resource "null_resource" "getting_nodes" {

  provisioner "local-exec" {

    command = "kubectl get nodes -n kube-system"
    
  }

  depends_on = [ kubernetes_config_map.aws_auth ]
  
}

