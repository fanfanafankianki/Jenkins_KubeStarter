
output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "public_subnet_ids"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "private_subnet_ids"
  value       = module.vpc.private_subnet_ids
}

output "sg_id" {
  description = "Security Group ID"
  value = aws_security_group.web_sg.id
}
