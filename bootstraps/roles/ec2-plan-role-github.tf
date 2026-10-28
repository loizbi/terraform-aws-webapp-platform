# Create the IAM policy for GitHub Actions
data "aws_iam_policy_document" "ec2_plan_github_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    # The principal is the OIDC provider for GitHub Actions
    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    # The request must come from the GitHub Actions OIDC provider
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    # The request must come from the specified GitHub repository & branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      # GitHub OIDC immutable subject format
      values = [
      "repo:${var.ec2_github_org}@${var.ec2_github_owner_id}/${var.ec2_github_repo_name}@${var.ec2_github_repo_id}:ref:refs/heads/${var.ec2_github_dev_branch}"]
    }
  }
}

# Create the IAM role for GitHub Actions
resource "aws_iam_role" "ec2_plan_github_role" {
  name               = "${var.ec2_plan_role}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_plan_github_assume_role.json
}

# Create the IAM policy for GitHub Actions
data "aws_iam_policy_document" "ec2_plan_github_policy" {

  # Allow Terraform to read EC2 infrastructure
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute"
    ]

    resources = [
      "*"
    ]
  }

  # Allow Terraform to read Route 53
  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:GetChange"
    ]

    resources = [
      "*"
    ]
  }

  # Allow Terraform to read the Terraform state
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_state_bucket}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        var.ec2_state_path,
        "${var.ec2_state_path}/*"
      ]
    }
  }

  # Allow Terraform to read state objects only
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_state_bucket}/${var.ec2_state_path}/*"
    ]
  }
}

# Create the read-only AWS policy for GitHub Actions
resource "aws_iam_policy" "ec2_plan_github_deploy" {
  name        = "${var.ec2_plan_role}-policy"
  description = "Read-only AWS permissions used by GitHub Actions for Terraform plan"
  policy      = data.aws_iam_policy_document.ec2_plan_github_policy.json
}

# Attach the read-only AWS policy to the plan role
resource "aws_iam_role_policy_attachment" "ec2_plan_github_deploy" {
  role       = aws_iam_role.ec2_plan_github_role.name
  policy_arn = aws_iam_policy.ec2_plan_github_deploy.arn
}