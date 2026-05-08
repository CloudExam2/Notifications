import boto3
import os

# 1. Setup Environment
PROFILE = 'iteso-lab'
os.environ['AWS_PROFILE'] = PROFILE
os.environ['SNS_TOPIC_ARN'] = 'arn:aws:sns:us-east-1:756385352121:Notification-Exam-Topic'

# 2. Import Lambda AFTER environment is set
from lambda_function import lambda_handler

# 3. Mock Event
mock_event = {
    "body": "{\"folio\": \"F-1234\", \"total\": \"550.00\"}"
}

print("--- Starting Local Test ---")
response = lambda_handler(mock_event, None)
print(response)