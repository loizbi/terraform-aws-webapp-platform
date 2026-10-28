output "ec2_security_group_id" {
  value = aws_security_group.ec2_security_group[*].id
}

output "ec2_instance_public_ip" {
  value = aws_instance.webserver[*].public_ip
}

output "ec2_instance_private_ip" {
  value = aws_instance.webserver[*].private_ip
}

output "ec2_fqdn" {
  value = aws_route53_record.ec2_fqdn[*].fqdn
}

output "ec2_instance_private_dns" {
  value = aws_instance.webserver[*].private_dns
}

output "ec2_instance_availability_zone" {
  value = aws_instance.webserver[*].availability_zone
}

output "tags_all" {
  value = aws_instance.webserver[*].tags_all
}