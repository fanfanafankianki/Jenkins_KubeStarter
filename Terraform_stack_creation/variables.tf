variable "git_token" {
  type = string
}

variable "ec2_count_master" {
  description = "EC2 MASTER INSTANCE COUNT"
  type        = number
  default     = 1
}

variable "ec2_instance_type_master" {
  description = "EC2 MASTER INSTANCE TYPE"
  type        = string
  default     = "t3.medium"
}

variable "ec2_count_worker" {
  description = "EC2 WORKER INSTANCE COUNT"
  type        = number
  default     = 5
}

variable "ec2_instance_type_worker" {
  description = "EC2 WORKER INSTANCE TYPE"
  type        = string
  default     = "t3.medium"
}

variable "ami_us_east_2_master" {
    description = "Master ami version"
    type        = string
    default     = "ami-0705384c0b33c194c"
}

variable "ami_us_east_2_worker" {
    description = "Worker ami version"
    type        = string
    default     = "ami-0705384c0b33c194c"
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
