
import json
import boto3
import requests

sns_topic_name = "PUSH_DISPACHER"

def lambda_handler(event, context):
    # Extract SQS message
    sqs_message = json.loads(event['Records'][0]['body'])
    
    # Extract data from SQS message
    amount = sqs_message['amount']
    document = sqs_message['document']
    
    # Prepare payload for the endpoint
    payload = {
        "amount": amount,
        "document": document
    }
    
    # Endpoint URL
    endpoint_url = "http://localhost:8082/banking/payment"
    
    # Send request to the endpoint
    try:
        response = requests.post(endpoint_url, json=payload)
        response.raise_for_status()  # Raise exception for error status codes
        send_success_message(payload)
    except requests.exceptions.RequestException as e:
        send_error_message(payload, str(e))

def get_sns_topic_arn(topic_name):
    # Create an SNS client
    sns_client = boto3.client('sns')

    # List topics and filter by topic name
    response = sns_client.list_topics()
    for topic in response['Topics']:
        if topic_name in topic['TopicArn']:
            return topic['TopicArn']

    # If the topic with the specified name is not found
    raise ValueError(f"SNS topic with name '{topic_name}' not found")

def send_success_message(payload):
    # Send success message to SNS topic
    sns_client = boto3.client('sns')
    sns_client.publish(
        TopicArn=get_sns_topic_arn(sns_topic_name),
        Message=json.dumps({"status": "success", "payload": payload})
    )
    # Send success message to another endpoint
    send_to_another_endpoint("complete", payload)

def send_error_message(payload, error_message):
    # Send error message to SNS topic
    sns_client = boto3.client('sns')
    sns_client.publish(
        TopicArn=get_sns_topic_arn(sns_topic_name),
        Message=json.dumps({"cause": "rejected", "payload": payload, "error_message": error_message})
    )
    # Send error message to another endpoint
    send_to_another_endpoint("reject", payload)

def send_to_another_endpoint(status, payload):
    # Endpoint URL for sending messages based on status
    another_endpoint_url = "http://localhost:8080/tax-payment/" + status

    # Send message to another endpoint
    requests.post(another_endpoint_url, json={"cause": status, "payload": payload})

