# Environment-specific variables
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "finops_email" {
  description = "Email address for FinOps alerts"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}