terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-example-10.2026"
    key            = "aws/bootstrap-finops/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}
