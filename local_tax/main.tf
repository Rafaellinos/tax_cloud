# Region
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  version                     = "= 5.45" # >= 5.46 keep getting client_keep_alive param error
}

# VPC and Subnets
resource "aws_vpc" "local_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.local_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}


resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.local_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_sqs_queue" "tax_payment_sqs" {
  name                      = "TAX_PAYMENT_SQS"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  visibility_timeout_seconds = 30
}

resource "aws_sns_topic" "push-dispacher" {
  name = "PUSH_DISPACHER" 
}

