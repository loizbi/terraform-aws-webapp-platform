
# Environment-specific variables
environment           = "dev"
domain                = "loizbi-example.com"
team                  = "devops"
team_email            = "example@loizbi-example.com"
# Approximate EC2 compute cost only: t3.micro at $0.0104/hour, $7.50 per month.
# Excludes EBS storage, public IPv4, data transfer, and other AWS charges.
team_monthly_budget   = "10"

# Resource-specific variables
aws_region        = "eu-west-2"
vpc_id            = "vpc-072c8eb4b4859fce4"
subnet_id         = "subnet-0ea09907731a8f24d"
ec2_ami_id        = "ami-0224ce6f9504665ee"
ec2_name          = "ec2-webapp-example"
ec2_instance_type = "t3.micro"
ec2_ssh_key_pair  = "test_putty"

# Security group rules for the EC2 instance
ec2_allowed_ips = [
  "1.1.1.1/32",
  "2.2.2.2/32"
]