resource "aws_security_group" "main" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  for_each = {
    for idx, rule in var.ingress_rules : "${idx}" => rule
  }

  security_group_id = aws_security_group.main.id
  ip_protocol       = each.value.protocol
  description       = each.value.description

  from_port = each.value.protocol != "-1" ? each.value.from_port : null
  to_port   = each.value.protocol != "-1" ? each.value.to_port : null

  cidr_ipv4                     = lookup(each.value, "cidr_ipv4", null)
  referenced_security_group_id = lookup(each.value, "source_sg_id", null)
}

resource "aws_vpc_security_group_egress_rule" "main" {
  for_each = {
    for idx, rule in var.egress_rules : "${idx}" => rule
  }

  security_group_id = aws_security_group.main.id
  ip_protocol       = each.value.protocol
  description       = each.value.description

  from_port = each.value.protocol != "-1" ? each.value.from_port : null
  to_port   = each.value.protocol != "-1" ? each.value.to_port : null

  cidr_ipv4                     = lookup(each.value, "cidr_ipv4", null)
  referenced_security_group_id = lookup(each.value, "destination_sg_id", null)
}
