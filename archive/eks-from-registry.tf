  
  variable "env_name" {
    type = string
    default = "eks-lab2"
  }

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

  
  resource "aws_security_group" "eks" {
    name        = "${var.env_name} eks cluster"
    description = "Allow traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
      description      = "World"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge({
      Name = "EKS ${var.env_name}",
      "kubernetes.io/cluster/${var.env_name}": "owned"
    }, var.tags)
  }



resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = merge(local.tags, { Name = "${local.name}-additional" })
}


module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "18.19.0"

    cluster_name                    = "eks-lab2"
    cluster_version                 = "1.24"
    cluster_endpoint_private_access = true
    cluster_endpoint_public_access  = true
    cluster_additional_security_group_ids = [aws_security_group.eks.id]

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      disk_size              = 30
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.eks.id,aws_security_group.additional.id]
    }

    eks_managed_node_groups = {
      green = {
        min_size     = 1
        max_size      = 2
        desired_size = 1
        
        instance_types = ["t3.medium"]
        capacity_type  = "SPOT"
        labels = {
        Environment = "test"
        # GithubRepo  = "terraform-aws-eks"
        # GithubOrg   = "terraform-aws-modules"
      }
 
        taints = {
        }
        tags = merge({
        Name = "EKS ${var.env_name}",
        "kubernetes.io/cluster/${var.env_name}": "owned"
      }, var.tags)
      }
    }

    tags = merge({
      Name = "EKS ${var.env_name}",
      "kubernetes.io/cluster/${var.env_name}": "owned"
    }, var.tags)
  }