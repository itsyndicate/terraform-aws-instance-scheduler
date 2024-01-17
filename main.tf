provider "aws" {
  region = "us-west-1" 
}

terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-db-state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  prefix             = "${var.project}-${terraform.workspace}"

  common_tags = {
    Environment = terraform.workspace
    env         = var.environment_tag
    Project     = var.project
    DevOps      = var.contact
    ManagedBy   = "Terraform"
  }
}

