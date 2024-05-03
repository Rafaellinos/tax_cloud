variable "otel_lgtm_image" {
  description = "Open Telemetry Grafana"
  default     = "grafana/otel-lgtm"
}

# ECS terraform
resource "aws_ecs_task_definition" "otel_td" {
  family                   = "otel"
  network_mode             = "awsvpc"
  container_definitions   = jsonencode([
    {
      name  = "otel_task_def"
      image = var.otel_lgtm_image
      cpu   = 128
      memory = 256
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "otel_service" {
  name            = "otel-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.otel_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }
  depends_on = [
    aws_ecs_task_definition.otel_td,
    aws_ecs_cluster.my_cluster
  ]
}
