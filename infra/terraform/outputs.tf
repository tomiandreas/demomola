output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
}

output "alb_dns" {
  value = aws_lb.wordpress_alb.dns_name
  description = "Public DNS of the Application Load Balancer"
}

output "wordpress_s3_bucket" {
  value = aws_s3_bucket.media.bucket
  description = "S3 bucket name for media backup"
}

output "cloudflare_record_fqdn" {
  value       = "${cloudflare_dns_record.www.name}.${data.cloudflare_zone.main.name}"
  description = "The full hostname pointing to the Load Balancer"
}
