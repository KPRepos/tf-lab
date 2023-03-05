# data "aws_security_group" "cicd" {
#   # vpc_id=data.aws_vpc.cicd.id
#   filter {
#     name   = "tag:workshop"
#     values = ["${aws_security_group.eks-cicd-sg.id}"]
#   }
# }




# data "aws_vpc" "cicd" {
#   default = false
#   filter {
#     # name   = "tag:workshop"
#     values = ["${data.terraform_remote_state.infra.outputs.vpc_id}"]
#   }
# }



