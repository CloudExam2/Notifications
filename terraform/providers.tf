terraform {
  backend "s3" {
    bucket         = "iteso-terraform-state-inaki-99"
    key            = "notifications/terraform.tfstate"
    region         = "us-east-1"
  }
}