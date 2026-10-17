
# Global Vars
variable "aws_region" {
  description = "Global AWS region where resources will be created"
  type        = string
}

variable "s3_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

# EC2 Vars
variable "ec2_plan_role" {
  description = "EC2 & S3 RO GitHub Repo Vars"
  type        = string
}

variable "ec2_github_org" {
  description = "EC2 - GitHub Organization name"
  type        = string
}

variable "ec2_github_repo_name" {
  description = "EC2 - GitHub repository name"
  type        = string
}

variable "ec2_github_repo_id" {
  description = "EC2 - GitHub repository ID"
  type        = string
}

variable "ec2_github_owner_id" {
  description = "EC2 - GitHub repository owner ID"
  type        = string
}
  
variable "ec2_github_prod_branch" {
  description = "EC2 - GitHub production branch name"
  type        = string
}

variable "ec2_github_prod_env" {
  description = "EC2 - GitHub production environment"
  type        = string
}

variable "ec2_github_dev_branch" {
  description = "EC2 - GitHub development branch name"
  type        = string
}

variable "ec2_role" {
  description = "EC2 - Role Name"
  type        = string
}

variable "ec2_state_path" {
  description = "S3 key prefix for the EC2 Terraform state"
  type        = string
}