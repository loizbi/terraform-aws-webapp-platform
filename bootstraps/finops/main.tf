# Create a cost anomaly detection monitor for the service 
resource "aws_ce_anomaly_monitor" "service_monitor" {
  name              = "Service Cost Monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

# Create a cost anomaly detection subscription for the service monitor
resource "aws_ce_anomaly_subscription" "alerts" {
  name      = "Cost Anomaly Alerts"
  frequency = "DAILY"

  # Associate the subscription with the service monitor
  monitor_arn_list = [aws_ce_anomaly_monitor.service_monitor.arn]

  subscriber {
    type    = "EMAIL"
    address = var.finops_email
  }

  # Define the threshold for triggering alerts based on the anomaly detection
  threshold_expression {
    dimension {
      key = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      # Dollar value threshold for triggering alerts
      values        = ["10"]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

resource "aws_budgets_budget" "finops_account_budget" {
  name         = "FinOps Account Budget"
  account_id   = var.aws_account_id
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.finops_email]
  }
}