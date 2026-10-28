
# Environment-specific variables
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "team" {
  description = "Team responsible for the EC2 instance"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

# Resource-specific variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ID where the EC2 instance will be launched, one per Availability Zone"
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.subnet_ids) > 0 && length(distinct(var.subnet_ids)) == length(var.subnet_ids)
    error_message = "The subnet_ids value must contain at least one unique subnet ID."
  }
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  
  validation {
    condition     = length(var.ec2_ami_id) > 4 && substr(var.ec2_ami_id, 0, 4) == "ami-"
    error_message = "The ec2_ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "ec2_name" {
  description = "EC2 instance name"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_ssh_key_pair" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "ec2_allowed_ips" {
  description = "EC2 IP addresses allowed to access the EC2 instance"
  type        = list(string)
}

variable "ec2_instance_count" {
  description = "EC2 Number of instances to create"
  type        = number
  nullable    = false

  validation {
    condition     = var.ec2_instance_count >= 1 && floor(var.ec2_instance_count) == var.ec2_instance_count
    error_message = "The ec2_instance_count value must be a positive whole number."
  }
}