locals {
  instance_name = "wordpress-server"
  s3_bucket     = "wordpress-media-backup-${random_id.bucket_id.hex}"
  alb_name      = "wordpress-alb"
  db_name       = "wordpress_db"
}