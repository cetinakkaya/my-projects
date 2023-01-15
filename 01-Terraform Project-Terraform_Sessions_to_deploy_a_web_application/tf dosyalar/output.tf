output "site_url" {
    value = "http://${aws_lb.alb.dns_name}"
}