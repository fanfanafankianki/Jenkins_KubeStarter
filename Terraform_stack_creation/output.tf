
output "vpc_id" {
  description = "something"
  value = module.vpc.vpc_id
}

output "example_output" {
  description = "A static example output"
  value       = module.vpc.example_output
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
  value       = module.ec2_master.sg_id
}

# output "data" {
#   description = "data"
#   value       = module.s3.s3_object_body
# }


# output "buckets" {
#   description = "data"
#   value       = module.s3.out
# }
