variable "region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "alternative_names" {
  type = list(string)
}