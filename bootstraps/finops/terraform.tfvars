# Global variables
aws_region   = "eu-central-1"

# Environment-specific variables
finops_email = "finops@loizbi-example.com"
# Dollar value threshold for triggering alerts
anomaly_threshold_usd = 5
# Dollar value threshold for triggering budget notifications
limit_amount_usd = 20
# Percentage value threshold for triggering budget notifications
notification_threshold_percentage_1 = 80
notification_threshold_percentage_2 = 100

# Don't declare so it will be prompted during terraform apply
# In GitHub Actions, you can set this as a variable and pass it as an environment variable to Terraform
#default_monitor_arn = ""