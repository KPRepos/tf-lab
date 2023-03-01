terraform {
  backend "s3" {
    bucket = "tf-lab-state-bucket"
    key    = "lab-latest.state"
    region = "us-west-2"
  }
}


provider "aws" {
  region = local.region
  ignore_tags {
    key_prefixes = ["kubernetes.io/role/*"]
  }
}
