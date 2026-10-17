output "ec2_security_group_id" {
  value = one(aws_instance.webserver01.vpc_security_group_ids)
}

output "ec2_instance_public_ip" {
  value = aws_instance.webserver01.public_ip
}

output "ec2_instance_private_ip" {
  value = aws_instance.webserver01.private_ip
}

output "ec2_fqdn" {
  value = aws_route53_record.ec2_fqdn.fqdn
}

output "ec2_instance_private_dns" {
  value = aws_instance.webserver01.private_dns
}

output "ec2_instance_availability_zone" {
  value = aws_instance.webserver01.availability_zone
}

output "tags_all" {
  value = aws_instance.webserver01.tags_all
}