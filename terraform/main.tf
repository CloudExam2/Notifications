provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  # Navigates: terraform/ -> root/ -> lambda_notifications/ -> file
  source_file = "${path.module}/../src/lambda_function.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# 1. SNS Topic
resource "aws_sns_topic" "sales_notifications" {
  name = var.sns_topic_name
}

# 2. SNS Subscription (Email)
resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.sales_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# 3. Lambda Function
# Automatically gets your current Account ID and Partition
data "aws_caller_identity" "current" {}

# Dynamically constructs the LabRole ARN
locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_lambda_function" "notification_service" {
  function_name = var.lambda_function_name
  role          = local.lab_role_arn  # Use singular 'local'
  package_type  = "Image"
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/notifications-service:latest"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sales_notifications.arn
    }
  }
}

# 7. Lambda Function URL (For Integration)
resource "aws_lambda_function_url" "notification_url" {
  function_name      = aws_lambda_function.notification_service.function_name
  authorization_type = "NONE"
}