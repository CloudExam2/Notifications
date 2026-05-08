terraform {
  backend "s3" {
    bucket         = "iteso-terraform-state-inaki"
    key            = "notifications/terraform.tfstate"
    region         = "us-east-1"
    # REMOVE dynamodb_table
    use_lockfile   = true 
    encrypt        = true
  }
}