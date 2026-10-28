
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

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ID where the EC2 instance will be launched, one per Availability Zone"
  type        = list(string)
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
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
}