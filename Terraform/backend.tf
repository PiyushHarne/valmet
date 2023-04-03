terraform {
  backend "s3" {
    bucket         = "terraform-state-piyush"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "piyushterraform1"
  }
}