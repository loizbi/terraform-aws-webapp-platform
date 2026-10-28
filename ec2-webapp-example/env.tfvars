
# Environment-specific variables
environment = "dev"
domain      = "loizbi-example.com"
team        = "devops"

# Resource-specific variables
aws_region         = "eu-west-2"
vpc_id             = "vpc-072c8eb4b4859fce4"
subnet_ids = [
  "subnet-0ea09907731a8f24d", # AZ-2a
  "subnet-09edddea6a0098dff", # AZ-2b
  "subnet-071333573a3b6a5f1", # AZ-2c
  "subnet-09274d1df09b36c0d", # AZ-2d
]
ec2_ami_id         = "ami-0224ce6f9504665ee" # Ubuntu Server 26.04
ec2_name           = "ec2-webapp-example"
ec2_instance_type  = "t3.micro" # Family: t3 | 2 vCPU | 1 GiB Memory
ec2_ssh_key_pair   = "test_putty"
ec2_instance_count = 2

# Security group rules for the EC2 instance
ec2_allowed_ips = [
  "1.1.1.1/32",
  "2.2.2.2/32"
]