resource "aws_sqs_queue" "tax_payment_sqs" {
  name                      = "TAX_PAYMENT_SQS"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  visibility_timeout_seconds = 30
}
