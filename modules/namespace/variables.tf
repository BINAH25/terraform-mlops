variable "namespace_name" {
  description = "Name of the service discovery namespace (e.g., myapp.local)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the namespace will be created"
  type        = string
}

variable "description" {
  description = "Description for the namespace"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the namespace"
  type        = map(string)
  default     = {}
}