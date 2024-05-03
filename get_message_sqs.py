import boto3

def get_queue_url(queue_name):
    sqs = boto3.client('sqs')
    response = sqs.get_queue_url(QueueName=queue_name)
    return response['QueueUrl']

def receive_messages(queue_name):
    queue_url = get_queue_url(queue_name)
    sqs = boto3.client('sqs')
    
    while True:
        response = sqs.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=10)
        if 'Messages' in response:
            for message in response['Messages']:
                print("Received message:", message['Body'])
                # Optionally, process the message further
                # If processing is successful, delete the message
                # sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=message['ReceiptHandle'])
        else:
            print("No messages available")
            break

if __name__ == "__main__":
    queue_name = "TAX_PAYMENT_SQS"  # Replace with your queue name
    receive_messages(queue_name)
