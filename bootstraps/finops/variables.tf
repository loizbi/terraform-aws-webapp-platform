# Account-specific variables
variable "default_monitor_arn" {
  description = "Default Monitor ARN for anomaly detection"
  type        = string
}

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

variable "teams" {
  description = "Team budgets and alert recipients, keyed by the Team tag value"
  type = map(object({
    monthly_budget = number
    email          = string
  }))

  validation {
    condition = alltrue([
      for team in values(var.teams) :
      can(regex("^[^@]+@[^@]+\\.[^@]+$", team.email))
    ])
    error_message = "Each team must have a valid email address."
  }
}