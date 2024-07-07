output "git_token" {
  value     = var.git_token
  sensitive = true
}

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

output "master_private_key_pem" {
  value     = tls_private_key.master.private_key_pem
  sensitive = true
}

output "worker_private_key_pem" {
  value     = tls_private_key.worker.private_key_pem
  sensitive = true
}

output "master_instance_public_ip" {
  description = "The public IP addresses of the master instances"
  value       = [for instance in aws_instance.master_instance : instance.public_ip]
}

output "worker_instance_public_ip" {
  description = "The public IP addresses of the worker instances"
  value       = [for instance in aws_instance.worker_instance : instance.public_ip]
}

output "efs_id" {
  value = module.vpc.efs_mount_target_ip
}

output "terraform_role_arn" {
  value = module.policy.terraform_role_arn
}


