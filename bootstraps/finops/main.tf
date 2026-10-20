
# Subscribe to the existing AWS-managed services monitor
resource "aws_ce_anomaly_subscription" "alerts" {
  name      = "Cost Anomaly Alerts"
  frequency = "DAILY"

  monitor_arn_list = [var.default_monitor_arn]

  subscriber {
    type    = "EMAIL"
    address = var.finops_email
  }

  # Alert when an anomaly's total impact reaches this USD threshold
  threshold_expression {
    dimension {
      key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [var.anomaly_threshold_usd]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

# Resolve the account from the active AWS credentials
data "aws_caller_identity" "current" {}

# Track total monthly AWS costs for the account running this configuration
resource "aws_budgets_budget" "finops_account_budget" {

  name         = "FinOps Account Budget"
  account_id   = data.aws_caller_identity.current.account_id
  budget_type  = "COST"
  limit_amount = var.limit_amount_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.notification_threshold_percentage_1
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.finops_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.notification_threshold_percentage_2
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.finops_email]
  }
}
