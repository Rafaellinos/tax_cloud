resource "aws_ecs_task_definition" "tax_service_td" {
  family                   = "TAX-SERVICE"
  network_mode             = "awsvpc"
  container_definitions   = jsonencode([
    {
      name  = "taxapi"
      image = "nerociffer/taxapi:latest"
      cpu   = 256
      memory = 512
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

resource "aws_ecs_service" "tax_service_service" {
  name            = "tax_service_service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.tax_service_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_a.id]
    security_groups  = [aws_security_group.ecs_sg.id]  # Specify security groups if needed
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_task_definition.tax_service_td,
    aws_ecs_cluster.my_cluster
  ]
}

resource "aws_lb_target_group" "tax_target_group" {
  name     = "tax-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_listener" "tax_listener" {
  load_balancer_arn = aws_lb.taxalb.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tax_target_group.arn
  }
}



resource "aws_lb_listener_rule" "tax_service_rule" {
  listener_arn = aws_lb_listener.tax_listener.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tax_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/tax/*", "/tax-payment/*"]
    }
  }
}


