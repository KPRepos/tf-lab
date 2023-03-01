# resource "aws_vpc" "labvpc" {
#   cidr_block = "10.0.0.0/16"
 
#   tags = {
#     Name = "labvpc"
#   }
# }

# resource "aws_subnet" "public" {
#   vpc_id     = aws_vpc.labvpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "public"
#   }
# }


# resource "aws_subnet" "private1" {
#   vpc_id     = aws_vpc.labvpc.id
#   cidr_block = "10.0.2.0/24"

#   tags = {
#     Name = "private"
#   }
# }

# resource "aws_subnet" "private1" {
#   vpc_id     = aws_vpc.labvpc.id
#   cidr_block = "10.0.2.0/24"

#   tags = {
#     Name = "private"
#   }
# }

# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.labvpc.id

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_eip" "natgatewayeip" {
# #   instance = aws_instance.web.id
# #   vpc      = true
# }


# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.natgatewayeip.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "Public-NAT"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_route_table" "public_nat_route_table" {
#   vpc_id = aws_vpc.labvpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "public_nat_route_table"
#   }
# }


# resource "aws_route_table" "private_nat_route_table" {
#   vpc_id = aws_vpc.labvpc.id

#   route {
#     cidr_block              = "0.0.0.0/0"
#     nat_gateway_id          = aws_nat_gateway.nat.id
#   }


#   tags = {
#     Name = "private_nat_route_table"
#   }
# }


# resource "aws_route_table_association" "nat_rt_association" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private_nat_route_table.id
# }

# resource "aws_route_table_association" "public_rt_association" {
#   # gateway_id     = aws_internet_gateway.gw.id
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public_nat_route_table.id
# }
