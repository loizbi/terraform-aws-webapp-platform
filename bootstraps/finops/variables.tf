# Environment-specific variables
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "finops_email" {
  description = "Email address for FinOps alerts"
  type        = string
}

variable "anomaly_threshold_usd" {
  description = "Threshold for triggering cost anomaly alerts in USD"
  type        = number
}

variable "limit_amount_usd" {
  description = "Budget limit amount in USD"
  type        = number
}

variable "notification_threshold_percentage_1" {
  description = "First threshold for triggering budget notifications as a percentage"
  type        = number
}

variable "notification_threshold_percentage_2" {
  description = "Second threshold for triggering budget notifications as a percentage"
  type        = number
}

variable "default_monitor_arn" {
  description = "Default Monitor ARN for anomaly detection"
  type        = string
}