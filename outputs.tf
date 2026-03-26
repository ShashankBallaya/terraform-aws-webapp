output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Visit this URL in your browser after apply"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "Connect to this from EC2 using MySQL client"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}