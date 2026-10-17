output "ec2_security_group_id" {
  value = module.ec2-simple-instance.ec2_security_group_id
}

output "ec2_instance_public_ip" {
  value = module.ec2-simple-instance.ec2_instance_public_ip
}

output "ec2_instance_private_ip" {
  value = module.ec2-simple-instance.ec2_instance_private_ip
}

output "ec2_fqdn" {
  value = module.ec2-simple-instance.ec2_fqdn
}

output "ec2_instance_private_dns" {
  value = module.ec2-simple-instance.ec2_instance_private_dns
}

output "ec2_instance_availability_zone" {
  value = module.ec2-simple-instance.ec2_instance_availability_zone
}

output "tags_all" {
  value = module.ec2-simple-instance.tags_all
}