output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.terraform_role.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.terraform_role.name
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.terraform_instance_profile.name
}

output "terraform_role_arn" {
  value = aws_iam_role.terraform_role.arn
  description = "The ARN of the IAM role for Kubernetes Terraform"
}
