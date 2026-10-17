# EC2 Simple Instance

This module provisions an EC2 instance and a Route 53 record in an existing public hosted zone.

The calling configuration must provide the AWS provider and values for the environment, domain, VPC, subnet, AMI, instance, SSH key pair, and allowed IP addresses. See [`ec2-webapp-example`](../../ec2-webapp-example) for an example.
