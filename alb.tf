# Application Load Balancer (ALB)
resource "aws_lb" "facebook_lb" {
  name               = "facebook-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.facebook_sg.id]
  subnets            = aws_subnet.public[*].id
}

# Target Group for ECS Service
resource "aws_lb_target_group" "facebook_tg" {
  name        = "facebook-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener for HTTP Traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.facebook_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.facebook_tg.arn
  }
}
