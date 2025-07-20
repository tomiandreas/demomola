terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare" 
      version = ">= 5.7.1"
    }
  }
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}