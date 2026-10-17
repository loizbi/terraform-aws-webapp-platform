# Terraform AWS Web App Platform

Terraform provisions an EC2 web server and Route 53 record. GitHub Actions runs a plan on `validation` and applies on `main` when `ec2-webapp-example/` changes. Ansible installs and configures Nginx.

**Technologies:** Terraform · AWS (EC2, S3, Route 53, IAM/OIDC) · GitHub Actions · Ansible · Nginx

## Requirements

- AWS account, AWS CLI configured with credentials, Terraform CLI (version requirements are declared in each Terraform configuration), GitHub CLI, and GitHub Actions enabled.
- An existing VPC, subnet, EC2 key pair, and public Route 53 hosted zone.

## Create the Terraform State Bucket

Authenticate to AWS with the CLI. Navigate to `bootstraps/backend`. The S3 backend block in `main.tf` must be commented out when creating the bucket for the first time, allowing Terraform to initialize with a local state file. Run:

```sh
terraform init
terraform apply
```

Then uncomment the S3 backend block, set it to the bucket name you created, and run `terraform init` again. Confirm migration of the local state to S3 with `terraform state list`.

## Create the GitHub OIDC Roles

GitHub OIDC uses immutable owner and repository IDs. From your repository, get them with:

```sh
gh api repos/<OWNER>/<REPO> --jq '"owner_id=\(.owner.id) repo_id=\(.id)"'
```

Navigate to `bootstraps/roles`. Update `backend.tf` to use your state bucket. In `terraform.tfvars`, set the bucket name, GitHub organization and repository name, owner and repository IDs, `validation` and `main` branch names, `ec2_github_prod_env = "environment:production"`, role names, and application state path. Then run:

```sh
terraform init
terraform apply
```

Keep the ARNs from outputs `AWS_IMA_ROLE-ec2_apply_github_role` and `AWS_IMA_ROLE-ec2_plan_github_role` for the GitHub settings below.

## Configure the GitHub Repository

Open **Settings → Secrets and variables → Actions** in your repository:

- Under **Variables**, add `AWS_APPLY_ROLE_ARN` and `AWS_PLAN_ROLE_ARN` with the matching role ARNs from the previous step.
- GitHub Actions debug logging is off by default. To enable it temporarily, add the `ACTIONS_STEP_DEBUG` secret with value `true`; remove it or set it to `false` when done.
- Under **Secrets**, add `AWS_SSH_PRIVATE_KEY` with the private SSH key matching your EC2 key pair.

The workflows use GitHub OIDC, so AWS access keys are not required. The role trust policies must match this repository and the `validation` and `main` branches.

## Configure the Web App and Workflows

Navigate to `ec2-webapp-example` and update `backend.tf` with your state bucket. Set the values in `env.tfvars`: `environment`, `team`, `domain`, `aws_region`, `vpc_id`, `subnet_id`, `ec2_ami_id`, `ec2_name`, `ec2_instance_type`, `ec2_ssh_key_pair`, and `ec2_allowed_ips`. The VPC, subnet, EC2 key pair, and public hosted zone `${environment}.${domain}` must already exist.

In `.github/workflows/terraform-validation.yml` and `terraform-main.yml`, set `working_directory` to `ec2-webapp-example` (or your chosen app directory). The workflows expect `env.tfvars` in that directory. They currently trigger only for changes under `ec2-webapp-example/`. The Ansible workflow temporarily allows SSH from its runner's public IP (`/32`) and revokes that rule afterward. `.gitignore` currently allows `.tfvars` files; commit `env.tfvars` only if it contains no secrets. Keep private keys in GitHub Secrets.

Trivy scans the Terraform configuration for high and critical security findings on `validation` and before deployment on `main`. Findings listed in `.trivyignore` are ignored. Remove an entry from `.trivyignore` when it no longer needs to be suppressed.

## Configure Production Protections

**AWS permission scope:** The GitHub Actions apply role needs write access to create and delete the infrastructure. This example grants broad EC2 permissions and `iam:PassRole` across AWS resources. `PR approval` controls which workflow changes reach `main`, but does not limit the role’s permissions. Review and narrow the IAM policy for your AWS account before reusing this configuration.

In **Settings → Rules → Rulesets**, create an active branch ruleset targeting `main`. Require a pull request and at least one approval, block force pushes and branch deletion, and limit bypass to trusted administrators. This ensures workflow changes, including removal of the destroy workflow's approval requirement, go through review.

A reviewer with write access must open the pull request and submit an **Approve** review; GitHub will block merging until the required approval is recorded. The PR author cannot approve their own pull request.

Configure required reviewers for the `production` Environment under **Settings → Environments → production**. This approval is required for the manual destroy workflow; normal applies are protected by the required PR approval and `main` branch protection.

After configuring the AWS backend, OIDC roles, repository variables and secrets, and workflow paths, commit and push the changes to GitHub to run the CI/CD workflows.

## Local Validation (Optional)
Run these from `ec2-webapp-example`:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=env.tfvars
```

## Push to `validation` and Open a Pull Request

Create and push the development branch:

```sh
git checkout -b validation
git add .
git commit -m "Initial deployment configuration"
git push -u origin validation
```

The `validation` push runs Terraform validation and plan. Open a pull request from `validation` to `main`, review it, and merge it. The push to `main` runs Terraform apply and Ansible deployment.

## Destroy Production Infrastructure

Run the manual destroy workflow from `main` and type `DESTROY` to confirm. Reviewers configured for the `production` Environment must approve the apply job before Terraform applies the full destroy plan.

### Destroy the GitHub OIDC Roles
Navigate to `bootstraps/roles` and run:
```sh
terraform destroy
```

### Destroy State Bucket

**⚠️ Warning:** Back up the Terraform state before proceeding. Destroying the S3 bucket permanently deletes all stored objects and versions, including any state backups.

Navigate to `bootstraps/backend`, comment out the S3 backend configuration in `main.tf` and migrate the state locally:
```sh
terraform init -migrate-state
```

Verify the local state with `terraform state list` before proceeding to destroy the bucket.

In `main.tf`, remove lifecycle `{ prevent_destroy = true }` from the `aws_s3_bucket.terraform_state` and set `force_destroy = true`. This allows Terraform to delete the S3 bucket and its object versions.
Run:

```sh
terraform init
terraform apply
terraform destroy
```
