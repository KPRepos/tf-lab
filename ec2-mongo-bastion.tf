resource "random_password" "bucket_hash" {
  length           = 7
  special          = false
  upper = false
}

resource "aws_s3_bucket" "public_s3_lab_mongo" {

  bucket = "public-s3-lab-mongo-${random_password.bucket_hash.result}"
  acl    = "public-read"
  force_destroy = true
  tags = {
    Name        = "public-s3-lab-mongo1"
    # Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "public_s3_lab_mongo_public_access_block" {
  bucket = aws_s3_bucket.public_s3_lab_mongo.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_everyone" {
  bucket = aws_s3_bucket.public_s3_lab_mongo.id
  policy = data.aws_iam_policy_document.allow_access_everyone.json
}

data "aws_iam_policy_document" "allow_access_everyone" {
  statement {
    actions = ["s3:ListBucket",]
    resources = [aws_s3_bucket.public_s3_lab_mongo.arn,]
    # effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
  statement {
    actions   = ["s3:GetObject",]
    resources =  [aws_s3_bucket.public_s3_lab_mongo.arn,"${aws_s3_bucket.public_s3_lab_mongo.arn}/*"]
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}



data "template_file" "mongo_user_data" {
  template = "${file("userdata-scripts/mongo_user_data.sh")}"

  vars = {
    backup_s3_bucket       = "${aws_s3_bucket.public_s3_lab_mongo.id}"
    aws_region = var.region
    Mongodb_repo_version = var.Mongodb_repo_version
    Mongodb_install_version = var.Mongodb_install_version
    
  }
}

resource "aws_instance" "MongoDB" {
  count = var.deploy_mongo  == "yes" ? 1 : 0
  ami                  = var.ami_id_mongo # older than 1 year
  instance_type        = "t3.small"
  user_data            = "${data.template_file.mongo_user_data.rendered}"
  iam_instance_profile = aws_iam_instance_profile.mongo-ec2-role.name
  vpc_security_group_ids = [aws_security_group.mongodb_security_group.id]
  subnet_id            = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "MongoDb"
  }

}


resource "aws_security_group" "bastion_security_group" {
  # ... other configuration ...
    ingress {
    description      = "port 22 Traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id      = module.vpc.vpc_id
tags = {
    Name = "bastion_security_group"
  }
}

resource "aws_security_group" "mongodb_security_group" {
  # ... other configuration ...
    ingress {
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  vpc_id      = module.vpc.vpc_id
tags = {
    Name = "mongodb_security_group"
  }
}

data "template_file" "bastion_user_data" {
  template = "${file("userdata-scripts/bastion_user_data.sh")}"
  # count = var.deploy_mongo  == "yes" ? 1 : 0
  vars = {
    backup_s3_bucket       = "${aws_s3_bucket.public_s3_lab_mongo.id}"
    # mongodb_dns = "${aws_instance.MongoDB.private_dns}"
    mongodb_dns = var.deploy_mongo == "yes" ? "${aws_instance.MongoDB[0].private_dns}" : "null"
    aws_region = var.region
  }
}

resource "aws_instance" "bastion" {
  count = var.deploy_bastion  == "yes" ? 1 : 0
  ami                  = var.ami_id_bastion 
  instance_type        = "t3.micro"
  # key_name             = var.key_name
  user_data            = "${data.template_file.bastion_user_data.rendered}"
  iam_instance_profile = aws_iam_instance_profile.bastion-ec2-role.name
  vpc_security_group_ids =  [aws_security_group.bastion_security_group.id]
  subnet_id            = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "bastion"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
 

#Creating a AWS secret 
 
resource "aws_secretsmanager_secret" "mongoadminUserpassword" {
  name = "mongoadminUserpassword"
  recovery_window_in_days = 0
}
 
# Creating a AWS secret versions 
 
resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.mongoadminUserpassword.id
  secret_string = <<EOF
  {
    "username": "adminUser",
    "password": "${random_password.password.result}"
  }
EOF
}
 
# Importing the AWS secrets created previously using arn.
 
data "aws_secretsmanager_secret" "mongoadminUserpassword" {
  arn = aws_secretsmanager_secret.mongoadminUserpassword.arn
}
 
# Importing the AWS secret version created previously using arn.
 
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.mongoadminUserpassword.arn
  depends_on = [
      aws_secretsmanager_secret.mongoadminUserpassword
  ]  
}
 
# After importing the secrets storing into Locals
 
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}
