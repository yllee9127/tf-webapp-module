output "webapp_public_ips" {
  value = aws_instance.web_app[*].public_ip
}

output "webapp_url" {
  value = var.alb_listener_arn != "" ? "http://${data.aws_lb.this[0].dns_name}/${var.name_prefix}" : ""
}
