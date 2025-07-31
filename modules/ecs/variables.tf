# variables.tf
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for the service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the service"
  type        = list(string)
}

variable "namespace_id" {
  description = "Service discovery namespace name"
  type        = string
}


variable "service_discovery_name" {
  description = "Service discovery service name"
  type        = string
}


variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  
}
variable "environment_variables" {
  description = "List of environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "assign_public_ip" {
  type = bool
  default = true
}

variable "enable_alb" {
  type        = bool
  description = "Enable ALB integration"
  default     = false
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the target group for ALB"
  default     = ""
}

variable "loki_url" {
  type = string
}