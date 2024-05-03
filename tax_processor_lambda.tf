
resource "aws_lambda_function" "tax_processor_function" {
  filename      = "./lambdas/tax_processor_function.zip"  # Path to your Lambda function code
  function_name = "tax_processor_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "tax_processor_function.lambda_handler"
  runtime       = "python3.12"
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy allowing Lambda to publish messages to SNS
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda-sns-policy"
  description = "Policy allowing Lambda to publish messages to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sns:Publish",
      Resource = "*" 
    }]
  })
}

# Attachment of Lambda role policy
resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# Policy allowing Lambda to receive messages from SNS
resource "aws_iam_policy" "lambda_sns_trigger_policy" {
  name        = "lambda-sns-trigger-policy"
  description = "Policy allowing Lambda to receive messages from SNS trigger"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "sns:GetTopicAttributes",
        "sns:Subscribe",
        "sns:Receive",
        "sns:DeleteMessage"
      ],
      Resource = "*" 
    }]
  })
}

# Attachment of Lambda role policy for SNS trigger
resource "aws_iam_role_policy_attachment" "lambda_sns_trigger_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_trigger_policy.arn
}

