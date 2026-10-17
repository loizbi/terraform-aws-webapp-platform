
output "AWS_IMA_ROLE-ec2_apply_github_role" {
    value = aws_iam_role.ec2_apply_github_role.arn
  
}

output "AWS_IMA_ROLE-ec2_plan_github_role" {
    value = aws_iam_role.ec2_plan_github_role.arn
  
}