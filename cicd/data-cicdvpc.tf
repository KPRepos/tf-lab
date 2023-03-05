# data "aws_vpc" "cicd" {
#   default = false
#   filter {
#     # name   = "tag:workshop"
#     values = ["${data.terraform_remote_state.infra.outputs.vpc_id}"]
#   }
# }

# vpc_id = data.aws_vpc.cicd.id

# data "aws_vpc" "cicd" {
#   default = false
#   filter {
#     name   = "tag:workshop"
#     values = ["eks-cicd"]
#   }
# }

# data "terraform_remote_state" "ecs" {
#     backend = "s3"
#     config {
#       bucket = "terraform-s3-backend-dd"
#       key    = "ECS/terraform.tfstate"
#       region = "us-west-2"
#     }
# }
