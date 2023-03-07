data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


data "terraform_remote_state" "infra" {
    backend = "s3"
    config = {
      bucket = "tf-lab-state-bucket"
      key    = "lab-latest.state"
      region = "us-west-2"
    }
}


# data "terraform_remote_state" "vpc" {
#     backend = "s3"
#     config {
#       bucket = "terraform-s3-backend-dd"
#       key    = "VPC/terraform.tfstate"
#       region = "us-west-2"
#     }
# }
