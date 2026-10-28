# Terraform AWS Web App Platform

Terraform provisions the specified number of EC2 web servers and a Route 53 record for each instance using the `ec2-simple-instance` module. GitHub Actions runs a plan on the `validation` branch and when `ec2-webapp-example/**` changes reach the `main` branch, it creates a saved plan and waits for approval in the `production` environment before applying it. Ansible installs and configures Nginx.

The bootstraps are managed independently and their configurations create the resources needed to manage and deploy the application: an S3 bucket for Terraform state and GitHub OIDC roles for Actions. Run them before deploying the app. FinOps monitoring is optional and configured separately.

**Technologies:** Terraform · AWS (EC2, S3, Route 53, IAM/OIDC) · GitHub Actions · Ansible · Nginx

## Requirements

- AWS account, AWS CLI configured with credentials, Terraform CLI (version requirements are declared in each Terraform configuration), GitHub CLI, and GitHub Actions enabled.
- An existing VPC and public subnets in that VPC with a route to an Internet Gateway and automatic public IPv4 assignment, an EC2 key pair, and a public Route 53 hosted zone. Route 53 and Ansible use each instance’s public IP address.
- For multi-AZ placement, provide one subnet per Availability Zone. 
- The example cycles through the list if the instance count exceeds the number of subnets.

## Create the Terraform State Bucket

Authenticate to AWS with the CLI. Navigate to `bootstraps/backend`. The S3 backend block in `main.tf` must be commented out when creating the bucket for the first time, allowing Terraform to initialize with a local state file. Run:

```sh
terraform init
terraform apply
```

Then uncomment the S3 backend block, set it to the bucket name you created, and run `terraform init` again. Confirm migration of the local state to S3 with `terraform state list`.

## Create the GitHub OIDC Roles

The `validation` plan disables state locking because its role has read-only access to the S3 state bucket. Avoid running a `validation` plan while an apply or destroy is in progress.

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

The workflows use GitHub OIDC, so AWS access keys are not required. The role trust policies must match this repository, the `validation` and `main` branches, and the `production` environment.

## Configure the WebApp and Workflows

Configure `ec2-webapp-example/backend.tf` and `env.tfvars` for your AWS account. `ec2_allowed_ips` controls inbound ICMP, HTTP, and SSH access.

The workflows currently target `ec2-webapp-example` and use `env.tfvars`. If you change those, update the workflow settings. `.tfvars` files are not ignored by default; keep secrets in GitHub Secrets.

Trivy scans the Terraform configuration for high and critical security findings on `validation` and before deployment on `main`. Findings listed in `.trivyignore` are ignored. Remove an entry from `.trivyignore` when it no longer needs to be suppressed.

## Configure Production Protections

**AWS permission scope:** The GitHub Actions apply role needs write access to create and delete the infrastructure. This example grants broad EC2 permissions and `iam:PassRole` across AWS resources. `PR approval` controls which workflow changes reach `main`, but does not limit the role’s permissions. Review and narrow the IAM policy for your AWS account before reusing this configuration.

In **Settings → Rules → Rulesets**, create an active ruleset for `main` that requires a pull request and at least one approval, blocks force pushes and branch deletion, and limits bypass to trusted administrators. The PR author cannot approve their own pull request.

Under **Settings → Environments → production**, configure required reviewers to approve both the `apply` and `manual destroy` jobs after their plans are generated. The `main` branch ruleset controls which changes can reach `main`.

## Local Validation (Optional)
Run these from `ec2-webapp-example`:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=env.tfvars
```

## Push to `validation` and Open a Pull Request

Create and push the validation branch:

```sh
git checkout -b validation
git add .
git commit -m "Initial deployment configuration"
git push -u origin validation
```

Open a pull request from `validation` to `main` and merge it after approval.

## Optional: FinOps Monitoring

The FinOps bootstrap creates account and per-team monthly budgets, plus daily cost anomaly alerts. Activate the `Team` cost allocation tag in Billing and Cost Management → Cost allocation tags. Its values must match the keys in `teams`. Configure `backend.tf` and `terraform.tfvars` in `bootstraps/finops`, then run:

```sh
terraform init
terraform plan
terraform apply
```

Terraform prompts for `default_monitor_arn` since it is omitted from `terraform.tfvars`.

## Destroy Production Infrastructure

Run the `manual` destroy workflow from `main` and type `DESTROY` to confirm. Review the generated destroy plan, then approve the job in the `production` environment.

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