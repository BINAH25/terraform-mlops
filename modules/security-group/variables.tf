variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where SG will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description    = string
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_ipv4      = optional(string)
    source_sg_id   = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description        = string
    from_port          = number
    to_port            = number
    protocol           = string
    cidr_ipv4          = optional(string)
    destination_sg_id  = optional(string)
  }))
  default = []
}
