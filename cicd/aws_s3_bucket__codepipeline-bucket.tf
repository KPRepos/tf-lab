
# data "external" "bucket_name" {
#   program = ["bash", "get-bucket-name.sh"]
# }

# output "Name" {
#   value = data.external.bucket_name.result.Name
# }


resource "random_password" "bucket_hash" {
  length           = 7
  special          = false
  upper = false
}

resource "aws_s3_bucket" "codepipeline-bucket" {
  bucket = "codep-tfeks-${random_password.bucket_hash.result}"
  tags           = {}
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "codepipeline-bucket" {
   # Enable versioning so we can see the full revision history of our
  # state files
  bucket = aws_s3_bucket.codepipeline-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_request_payment_configuration" "codepipeline-bucket" {
  bucket = aws_s3_bucket.codepipeline-bucket.id
  payer  = "BucketOwner"
}

resource "aws_s3_bucket_acl" "codepipeline-bucket" {
  bucket = aws_s3_bucket.codepipeline-bucket.id
  acl    = "private"
}

