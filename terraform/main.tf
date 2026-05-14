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

# 2. SNS Subscription
resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.sales_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# 3. Lambda Function
data "aws_caller_identity" "current" {}

locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_lambda_function" "notification_service" {
  function_name = var.lambda_function_name
  role          = local.lab_role_arn
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.notification.repository_url}:latest"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sales_notifications.arn
    }
  }
}

# 4. Lambda Function URL (Fixes Error: Unsupported argument/block)
resource "aws_lambda_function_url" "notification_url" {
  function_name      = aws_lambda_function.notification_service.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["POST"]
  }
}

# 5. SQS Trigger (Fixes Error: Reference to undeclared resource)
data "aws_sqs_queue" "ticket_queue" {
  name = "sales-ticket-queue"
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = data.aws_sqs_queue.ticket_queue.arn
  # Matches the resource name defined above
  function_name    = aws_lambda_function.notification_service.arn
  enabled          = true
  batch_size       = 10
}