
# Use the ec2-server module to create an EC2 instance for the web application
module "ec2-simple-instance" {
  source = "../modules/ec2-simple-instance"

  # Pass variables to the module

  # Environment-specific variables
  environment = var.environment
  domain      = var.domain
  team        = var.team

  # Resource-specific variables
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  ec2_ami_id         = var.ec2_ami_id
  ec2_name           = var.ec2_name
  ec2_instance_type  = var.ec2_instance_type
  ec2_ssh_key_pair   = var.ec2_ssh_key_pair
  ec2_allowed_ips    = var.ec2_allowed_ips
  ec2_instance_count = var.ec2_instance_count
}