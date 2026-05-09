import json
import os
import boto3

def lambda_handler(event, context):
    # 1. Parse the body (it comes as a string)
    try:
        if 'body' in event:
            data = json.loads(event['body'])
        else:
            data = event # Fallback for manual console tests
    except Exception as e:
        print(f"Error parsing body: {e}")
        data = {}

    # 2. Extract values with fallbacks
    # Ensure these keys match exactly what you send in PowerShell
    item  = data.get('item', 'N/A')
    price = data.get('price', '0')
    user  = data.get('user', 'Unknown')

    # 3. Create the message
    message = f"New Sale! \nUser: {user}\nItem: {item}\nPrice: ${price}"
    
    # 4. Send to SNS
    sns = boto3.client('sns')
    sns.publish(
        TopicArn=os.environ['SNS_TOPIC_ARN'],
        Message=message,
        Subject="Successful Sale Notification"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"status": "Email sent", "received": data})
    }