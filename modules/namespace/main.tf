resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace_name
  vpc         = var.vpc_id
  description = var.description

  tags = var.tags
}