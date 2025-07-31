module "vpc" {
  source       = "./modules/vpc"
  environment  = var.environment
  project_name = var.project_name
}

# Create an ECS Cluster where services will run
module "ecs_cluster" {
  source       = "./modules/ecs-cluster"
  cluster_name = var.cluster_name
}

# Create all required security groups (ALB, ECS, etc.) within the VPC
# ALB Security Group
module "alb_sg" {
  source      = "./modules/security-group"
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP and HTTPS access to ALB from anywhere"
  vpc_id      = module.vpc.vpc_id
  tags        = { Environment = var.environment }

  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}


# ECS Frontend Security Group
module "ecs_frontend_sg" {
  source      = "./modules/security-group"
  name        = "${var.project_name}-ecs-frontend-sg"
  description = "Allow HTTP access to ECS Frontend from ALB"
  vpc_id      = module.vpc.vpc_id
  tags        = { Environment = var.environment }

  ingress_rules = [
    {
      description      = "Allow HTTP from ALB"
      from_port        = 8000
      to_port          = 8000
      protocol         = "tcp"
      source_sg_id     = module.alb_sg.security_group_id
    },
    {
      description = "Allow Eureka"
      from_port   = 9779
      to_port     = 9779
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },

  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}
#Monitoring Security Group
module "monitoring_sg" {
  source      = "./modules/security-group"
  name        = "${var.project_name}-monitoring-sg"
  description = "Allow inbound traffic for monitoring"
  vpc_id      = module.vpc.vpc_id
  tags        = { Environment = var.environment }

  ingress_rules = [
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow Prometheus"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow Loki"
      from_port   = 3100
      to_port     = 3100
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

# module "route53" {
#   source       = "./modules/route53"
#   domain_name  = var.domain_name
#   alb_dns_name = module.alb.dns_name
#   alb_zone_id  = module.alb.alb_zone_id
# }


# module "alb" {
#   source            = "./modules/alb"
#   name              = "mlops-alb"
#   security_groups   = [module.alb_sg.security_group_id]
#   subnets           = module.vpc.public_subnet_ids
#   vpc_id            = module.vpc.vpc_id
#   target_group_name = "mlops-tg"
#   health_check_path = "/"
#   acm_cert_arn      = module.acm.acm_cert_arn
# }

# # Request and validate ACM SSL certificate for HTTPS
# module "acm" {
#   source            = "./modules/acm"
#   domain_name       = var.domain_name
#   hosted_zone_id    = module.route53.hosted_zone_id
#   alternative_names = []
# }


module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.monitoring_sg.security_group_id]
  instance_name = "prometheus-grafana"
  key_name = "mlops"
  user_data_install_docker = file("../scripts/install_docker.sh")
}