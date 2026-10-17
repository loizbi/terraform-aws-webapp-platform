
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.16.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Team        = var.team
      TeamEmail   = var.team_email
      TeamBudget  = var.team_monthly_budget
      ManagedBy   = "terraform"
    }
  }
}