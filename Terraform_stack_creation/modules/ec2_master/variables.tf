variable "ec2_count" {
  description = "EC2 INSTANCE COUNT"
  type        = number
  default     = 1
}

variable "ec2_instance_type" {
  description = "INSTANCE TYPE"
  type        = string
  default     = "t3.micro"
}


variable "ami_us_east_2" {
    description = "ami version"
    type        = string
    default     = "ami-0705384c0b33c194c"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_group" {
    description = "Configuration for security group"
    type  = object({
        sg_name     = string
        ssh_port    = number
        protocol    = string
        cidr_blocks = list(string)
    })
    default = {
        sg_name     = "ssh"
        ssh_port    = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
