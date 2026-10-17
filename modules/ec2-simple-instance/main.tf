
# Create a simple EC2 instance with a security group and a Route53 record
resource "aws_instance" "webserver01" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_ssh_key_pair
  vpc_security_group_ids = [
    aws_security_group.ec2_security_group.id
  ]
  subnet_id = var.subnet_id
  
  # Enable encryption for the root block device
  root_block_device {
    encrypted = true
  }
  
  # Enable IMDSv2 for the instance
  metadata_options {
  http_tokens = "required"
  }
  
  # Use the user_data_replace_on_change argument to force a replacement of the instance when the user data changes
  user_data_replace_on_change = true
  
  # Tag the instance with the Name tag  
  tags = {
    Name        = var.ec2_name
  }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name   = "${var.ec2_name}-sg"
  vpc_id = var.vpc_id

  # Use the create_before_destroy lifecycle argument to ensure that the security group is created before the instance is destroyed 
  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.ec2_allowed_ips
    description = "Public ICMP Access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ec2_allowed_ips
    description = "Python HTTP server access"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_allowed_ips
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Outbound access"
  }
  
  # Tag the security group with the Name tag
  tags = {
    Name        = "${var.ec2_name}-sg"
  }

}

# Look up the existing environment hosted zone
data "aws_route53_zone" "existing_zone" {
  name         = "${var.environment}.${var.domain}"
  private_zone = false
}

# Create a Route53 record for the EC2 instance 
resource "aws_route53_record" "ec2_fqdn" {
  #zone_id = aws_route53_zone.existing_zone.zone_id
  # This will use the existing zone
  zone_id = data.aws_route53_zone.existing_zone.zone_id
  name    = var.ec2_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.webserver01.public_ip]
}

# Create a budget for the team
resource "aws_budgets_budget" "team_monthly" {
  name         = "team-${var.team}-monthly"
  budget_type  = "COST"
  limit_amount = var.team_monthly_budget
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  # Use the cost_filter argument to filter the budget by the team tag 
  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Team$ ${var.team}"]
  }
  
  # Use the notification argument to send an email when the budget is exceeded 
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.team_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.team_email, "another_email@example.com"]
  }
}