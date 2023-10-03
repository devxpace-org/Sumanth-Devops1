terraform {
  backend "s3" {
    bucket = "dove12"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}