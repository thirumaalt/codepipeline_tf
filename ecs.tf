# ECS Cluster
resource "aws_ecs_cluster" "facebook_cluster" {
  name = "facebook-cluster"
}

# IAM Role for ECS
resource "aws_iam_policy" "cloudwatch_logs" {
  name = "ecs-cloudwatch-logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.facebook_logs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_role_policy" {
  name       = "ecs-execution-role-policy"
  roles      = [aws_iam_role.ecs_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "facebook" {
  family                   = "facebook-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "facebook-container"
      image     = "${aws_ecr_repository.facebook_repo.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/facebook-service"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "facebook_service" {
  name            = "facebook-service"
  cluster         = aws_ecs_cluster.facebook_cluster.id
  task_definition = aws_ecs_task_definition.facebook.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.facebook_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.facebook_tg.arn
    container_name   = "facebook-container"
    container_port   = 80
  }

  desired_count = 1
}
resource "aws_cloudwatch_log_group" "facebook_logs" {
  name              = "/ecs/facebook-service"
  retention_in_days = 30 # Optional: Adjust as needed
}
