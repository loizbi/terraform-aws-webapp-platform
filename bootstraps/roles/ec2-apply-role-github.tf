# Creating the IAM policy for GitHub Actions
data "aws_iam_policy_document" "ec2_apply_github_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    # The principal is the OIDC provider for GitHub Actions
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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
        "repo:${var.ec2_github_org}@${var.ec2_github_owner_id}/${var.ec2_github_repo_name}@${var.ec2_github_repo_id}:ref:refs/heads/${var.ec2_github_prod_branch}",

        "repo:${var.ec2_github_org}@${var.ec2_github_owner_id}/${var.ec2_github_repo_name}@${var.ec2_github_repo_id}:${var.ec2_github_prod_env}"
      ]


    }
  }
}

# Create the IAM role for GitHub Actions
resource "aws_iam_role" "ec2_apply_github_role" {
  name               = "${var.ec2_role}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_apply_github_assume_role.json
}

# Create the IAM policy for GitHub Actions
data "aws_iam_policy_document" "ec2_apply_github_policy" {

  # Allow EC2 full access
  statement {
    effect = "Allow"

    actions = [
      "ec2:*"
    ]

    resources = [
      "*"
    ]
  }

  # Allow Route 53
  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:GetChange"
    ]

    resources = ["*"]
  }

  # Allows Terraform to pass an IAM role to EC2
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }

  # Allow Terraform to access this project's S3 state
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

  # Allow Terraform to manage objects inside this project's state path
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_state_bucket}/${var.ec2_state_path}/*"
    ]
  }
}

# Deploy the IAM policy for GitHub Actions
resource "aws_iam_policy" "ec2_apply_github_deploy" {
  name        = "${var.ec2_role}-policy"
  description = "Policy used by GitHub Actions to manage EC2 infrastructure"
  policy      = data.aws_iam_policy_document.ec2_apply_github_policy.json
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_apply_github_deploy" {
  role       = aws_iam_role.ec2_apply_github_role.name
  policy_arn = aws_iam_policy.ec2_apply_github_deploy.arn
}