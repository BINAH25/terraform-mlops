# --------------------------------------------
# IAM Role for ECS Task Execution
# --------------------------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.service_name}-ecs-execution-role"

  # Trust policy to allow ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach standard execution permissions (e.g., pull images, write logs)
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# --------------------------------------------
# IAM Role for ECS Task
# --------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.service_name}-ecs-task-role"

  # Trust policy to allow ECS tasks to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# --------------------------------------------
# CloudWatch Log Group for FireLens Logs
# --------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.service_name}/log-router"
  retention_in_days = 1
}


# --------------------------------------------
# ECS Task Definition
# --------------------------------------------
resource "aws_ecs_task_definition" "main" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Role for pulling images, writing logs
  task_role_arn            = aws_iam_role.ecs_task_role.arn        # Role for S3/Bedrock access

  container_definitions = jsonencode([
    # 🔄 FireLens log router container
    {
      name      = "log-router"
      image     = "grafana/fluent-bit-plugin-loki:latest"
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.service_name}/log-router"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "firelens"
        }
      }
    },


    {
      name  = var.service_name
      image = var.container_image

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables 
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name         = "loki"
          Host         = var.loki_url
          Port         = "3100"
          uri          = "/loki/api/v1/push"
          label_keys   = "$container_name,$ecs_task_definition,$source,$ecs_cluster"
          remove_keys  = "container_id,ecs_task_arn"
          line_format  = "key_value"
        }
      }

      systemControls = []
      essential      = true
    },

    {
      name  = "ecs-exporter"
      image = "quay.io/prometheuscommunity/ecs-exporter:v0.4.0"
      portMappings = [
        {
          containerPort = 9779
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = var.tags
}

# --------------------------------------------
# ECS Service Discovery (for internal DNS)
# --------------------------------------------
resource "aws_service_discovery_service" "main" {
  name = var.service_discovery_name

  dns_config {
    namespace_id = var.namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  tags = var.tags
}

# --------------------------------------------
# ECS Service
# Deploys and manages Fargate tasks
# --------------------------------------------
resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  # Fargate Spot to reduce costs
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  # Register with internal service discovery
  service_registries {
    registry_arn = aws_service_discovery_service.main.arn
  }

  # Conditionally attach to load balancer
  dynamic "load_balancer" {
    for_each = var.enable_alb ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.service_name
      container_port   = var.container_port
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution_role_policy
  ]

  tags = var.tags
}
