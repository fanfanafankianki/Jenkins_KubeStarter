variable "tfe_token" {
  description = "Terraform Cloud API token"
  type        = string
  sensitive   = true
}

variable "ec2_count" {
  description = "EC2 COUNT"
  type        = number
  default     = 1
}

variable "ec2_instance_type" {
  description = "EC2 INSTANCE TYPE"
  type        = string
  default     = "t3.micro"
}
