provider "aws" {
  region = "us-east-1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  # Navigates: terraform/ -> root/ -> lambda_notifications/ -> file
  source_file = "${path.module}/../lambda_notifications/lambda_function.py"
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
resource "aws_lambda_function" "notification_service" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  function_name    = var.lambda_function_name
  role             = var.lab_role_arn  # Direct reference to pre-existing role
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"

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