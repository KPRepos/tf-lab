terraform {
  backend "s3" {
    bucket = "tf-lab-state-bucket"
    key    = "lab.state"
    region = "us-west-2"
  }
}

