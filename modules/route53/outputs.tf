output "root_record_fqdn" {
  value = aws_route53_record.failover_root.fqdn
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}

