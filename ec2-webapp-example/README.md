# EC2 Web App Example

This Terraform configuration uses the `ec2-simple-instance` module to create an EC2 instance and a Route 53 record.

Set the required values in `env.tfvars`, then run `terraform init`, `terraform plan -var-file=env.tfvars`, and `terraform apply -var-file=env.tfvars`. The VPC, subnet, EC2 key pair, and public hosted zone must already exist.

See the [root README](../README.md) for backend, GitHub Actions, and deployment setup.
