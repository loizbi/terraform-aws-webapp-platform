terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-example-10.2026"
    key          = "aws/ec2-webapp-example/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}