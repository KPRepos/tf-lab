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
 