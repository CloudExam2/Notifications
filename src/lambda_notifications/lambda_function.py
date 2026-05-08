import json
import boto3
import os

def lambda_handler(event, context):
    # Initialize client ONLY when function is called
	sns_client = boto3.client('sns')
	topic_arn = os.getenv('SNS_TOPIC_ARN')
	print(f"DEBUG: TopicArn being used is -> '{topic_arn}'")
	
	try:
        # Handle both direct JSON and API Gateway stringified body
		if isinstance(event.get('body'), str):
			body = json.loads(event['body'])
		else:
			body = event.get('body', event)

		folio = body.get('folio', 'N/A')
		total = body.get('total', '0.00')
        
		message = f"New Sale Created\nFolio: {folio}\nTotal: ${total}"
        
		response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject="Notification: New Sale"
        )
        
		return {
            'statusCode': 200,
            'body': json.dumps({'id': response['MessageId']})
        }
	except Exception as e:
		return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}