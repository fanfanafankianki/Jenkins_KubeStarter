
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

output "private_key_pem_master" {
  value     = tls_private_key.master.private_key_pem
  sensitive = true
}

output "private_key_pem_worker" {
  value     = tls_private_key.worker.private_key_pem
  sensitive = true
}

output "master_instance_public_ip" {
  description = "The public IP address of the master instance"
  value       = aws_instance.master_instance.public_ip
}

output "worker_instance_public_ip" {
  description = "The public IP address of the master instance"
  value       = aws_instance.worker_instance.public_ip
}
