provider "aws" {
  region = "us-east-1"
}

data "aws_ecr_repository" "notification" {
  name = "notification-service"
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
  role          = local.lab_role_arn
  package_type  = "Image"
  
  # FIX: Using the data source directly is safer than constructing strings
  image_uri     = "${data.aws_ecr_repository.notification.repository_url}:latest"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sales_notifications.arn
    }
  }
}

# 4. The trigger from SQS
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = data.aws_sqs_queue.ticket_queue.arn # Found via data block
  function_name    = aws_lambda_function.notification_service.arn
  batch_size       = 10
}