#custom variables outside of modules
variable "cluster-name" {
  # default     = "eks-lab"
  type        = string
  description = "The name of your EKS Cluster"
}

variable "region" {
  # default     = "us-west-2"
  type        = string
  description = "The AWS Region to deploy EKS"
}


variable "key_name" {
  type        = string
  description = "ec2 key"
}


