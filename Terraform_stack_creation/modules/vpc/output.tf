#output "subnet_id" {
#  value = aws_subnet.private_subnets[*].id
#}

output "example_output" {
  description = "A static example output"
  value       = "Hello, Terraform!"
}

output "vpc_id" {
  description = "something"
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public_subnets)[*].id
}

output "private_subnet_ids" {
  value = values(aws_subnet.private_subnets)[*].id
}

