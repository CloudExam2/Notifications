terraform {
  backend "s3" {
    bucket         = "iteso-terraform-state-inaki-69"
    key            = "notifications/terraform.tfstate"
    region         = "us-east-1"
  }
}