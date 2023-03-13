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

variable "env_name" {
  # default     = "us-west-2"
  type        = string
  description = "The environment key to append to resources"
}

#Not required, as session manager is in use 
# variable "key_name" {
#   type        = string
#   description = "ec2 key"
# }

variable "ami_id_mongo" {
  type        = string
  description = "ami_id"
}

variable "ami_id_bastion" {
  type        = string
  description = "ami_id"
}

 

variable "deploy_bastion" {
  type        = string
  description = "deploy instance"
  default = "yes"
}


variable "deploy_mongo" {
  type        = string
  description = "deploy instance"
  default = "yes"
}

variable "Mongodb_install_version" {
  type        = string
  description = "version"
}

variable "Mongodb_repo_version" {
  type        = string
  description = "version"
}