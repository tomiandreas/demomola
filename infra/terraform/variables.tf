variable "aws_access_key" {}

variable "aws_secret_key" {}


variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "availability_zone" {
  description = "AZ for subnet and ALB"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone (domain)"
  type        = string
}

variable "cloudflare_record_name" {
  description = "Subdomain name for the Cloudflare record"
  type        = string
}

variable "cloudflare_account_id" {
  type = string
}
variable "cloudflare_zone_id" {
  type = string
}
