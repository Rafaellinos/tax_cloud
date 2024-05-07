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
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  #map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  #map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  #map_public_ip_on_launch = false
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1a"
  #map_public_ip_on_launch = false
}


resource "aws_ecs_task_definition" "prodesp_acl_td" {
  family                   = "PRODESP-ACL"
  network_mode             = "awsvpc"
  container_definitions   = jsonencode([
    {
      name  = "prodespAcl"
      image = "nerociffer/prodesp-tributo:latest"
      cpu   = 256
      memory = 512
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
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


resource "aws_ecs_service" "prodesp_acl_service" {
  name            = "prodesp-acl-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.prodesp_acl_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.prodesp_acl_td,
    aws_ecs_cluster.my_cluster
  ]
}


