output "vpc_id" {
  description = "vpc id"
  value = "${module.vpc.vpc_id}"
  }
  
 output "private_subnets" {
   description = "Subnet ID"
   value = "${module.vpc.private_subnets}"
 }
 
  output "public_subnets" {
   description = "Subnet ID"
   value = "${module.vpc.public_subnets}"
 }
 
 
 
 
#  "${module.vpc.aws_subnet.private[1]}
 
# #  "${module.vpc.aws_subnet.public[0]}
 
#  "${module.vpc.aws_subnet.public[1]}

#  module.vpc.private_subnets[0]