# SG

resource "aws_security_group" "alb_sg" {
 name        = "alb_sg"
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
    Name = "alb_sg"
 }
}

# ALB
resource "aws_lb" "taxalb" {
  name               = "taxalb"
  internal           = false
  load_balancer_type = "application"
  #client_keep_alive  = 3600
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.public_subnet_c.id
  ]
}

# ALB Target Groups
resource "aws_lb_target_group" "tax_api_target_group" {
  name     = "tax-api-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group" "prodesp_acl_target_group" {
  name     = "prodesp-acl-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group" "payment_acl_target_group" {
  name     = "payment-acl-tg"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# ALB listener
resource "aws_lb_listener" "tax_api_listener" {
  load_balancer_arn = aws_lb.taxalb.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tax_api_target_group.arn
  }
}

resource "aws_lb_listener" "prodesp_acl_listener" {
  load_balancer_arn = aws_lb.taxalb.arn
  port              = 8081
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prodesp_acl_target_group.arn
  }
}

resource "aws_lb_listener" "payment_acl_listener" {
  load_balancer_arn = aws_lb.taxalb.arn
  port              = 8082
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payment_acl_target_group.arn
  }
}

#ALB Listener Rules
resource "aws_lb_listener_rule" "tax_api_listener_rule" {
  listener_arn = aws_lb_listener.tax_api_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tax_api_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/tax/*"]
    }
  }
}

resource "aws_lb_listener_rule" "prodesp_acl_listener_rule" {
  listener_arn = aws_lb_listener.prodesp_acl_listener.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prodesp_acl_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/prodesp/*"]
    }
  }
}

resource "aws_lb_listener_rule" "payment_acl_listener_rule" {
  listener_arn = aws_lb_listener.payment_acl_listener.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.payment_acl_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/payment/*"]
    }
  }
}

