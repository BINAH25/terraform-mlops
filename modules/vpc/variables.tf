variable "environment" {
  description = "The project environment, could be one of [production, staging, development, qa]"
  type = string
}

variable "enable_nat_gateway" {
  description = "The AWS region where resources will be deployed."
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "The AWS region where resources will be deployed."
  type        = bool
  default     = false
}


variable "project_name" {
  description = "A name prefix for all resources to help with identification."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "availability_zones" {
  description = "A list of Availability Zones to use for subnets."
  type        = list(string)
  default     = [
    "eu-west-1a",
    "eu-west-1b"
  ]
}