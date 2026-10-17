
# Global Vars
aws_region = "eu-central-1"
s3_state_bucket = "terraform-state-bucket-example-10.2026"

# EC2 & S3 Plan GitHub Repo Vars
ec2_plan_role     = "github-plan-ec2-example"

# EC2 & S3 Apply GitHub Repo Vars
ec2_github_org            = "loizbi"
ec2_github_repo_name      = "terraform-aws-webapp-platform"
ec2_github_owner_id       = "62348637"
ec2_github_repo_id        = "1423128271"
ec2_github_prod_branch    = "main"
ec2_github_prod_env       = "environment:production"
ec2_github_dev_branch     = "validation"
ec2_role                  = "github-apply-ec2-example"
ec2_state_path            = "aws/ec2-webapp-example"