terraform {
  backend "s3" {
    bucket = "tf-lab-state-bucket"
    key    = "lab-latest-code-star.state"
    region = "us-west-2"
  }
}


provider "aws" {
  region = "us-west-2"
}
