variable "docker_image" {
  description = "The Docker image for the APIs"
  default     = "nginxdemos/nginx-hello"
}

# Region
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  version                     = "= 5.45" # >= 5.46 keep getting client_keep_alive param error
}

# VPC and Subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "tax_api" {
  family                   = "TAX-API"
  container_definitions   = jsonencode([
    {
      name  = "taxApi"
      image = var.docker_image
      memory = 128
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "prodesp_acl" {
  family                   = "PRODESP-ACL"
  container_definitions   = jsonencode([
    {
      name  = "prodespAcl"
      image = var.docker_image
      memory = 128
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "payment_acl" {
  family                   = "PAYMENT-ACL"
  container_definitions   = jsonencode([
    {
      name  = "paymentAcl"
      image = var.docker_image
      memory = 128 
     portMappings = [
        {
          containerPort = 8080
          hostPort      = 8082
          protocol      = "tcp"
        }
      ] 
    }
  ])
}

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "tax-cluster"
}

# ECS SG
resource "aws_security_group" "ecs_sg" {
 name        = "ecs_sg"
 description = "Security group for ALB allowing all in/out traffic"

 ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
    Name = "ecs_sg"
 }
}

# ECS Services
resource "aws_ecs_service" "tax_api_service" {
  name            = "tax-api-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.tax_api.arn
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "prodesp_acl_service" {
  name            = "prodesp-acl-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.prodesp_acl.arn
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_subnet_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "payment_acl_service" {
  name            = "payment-acl-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.payment_acl.arn
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_subnet_c.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }
}

