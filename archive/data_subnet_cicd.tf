# data "aws_subnet" "cicd" {

#   filter {
#     name   = "tag:workshop"
#     values = ["${data.terraform_remote_state.infra.outputs.public_subnets[0]}"]
#   }
# }



# data "aws_vpc" "cicd" {
#   default = false
#   filter {
#     name   = "tag:workshop"
#     values = ["${data.terraform_remote_state.infra.outputs.vpc_id}"]
#   }
# }
# module.vpc.aws_subnet.private[0]
# module.vpc.aws_subnet.private[0]

# data "aws_subnet" "cicd" {

#   filter {
#     name   = "tag:workshop"
#     values = ["cicd-private1"]
#   }
# }