output "target_group_arns" {
  value = aws_lb_target_group.target_group[*].arn
}

output "DNS_LB" {
  value = aws_lb.Load_balancer.dns_name
}