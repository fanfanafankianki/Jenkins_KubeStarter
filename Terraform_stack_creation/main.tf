module "vpc" {
 source = "./modules/vpc/"
}

module "policy" {
 source = "./modules/policy/"
}

locals {
  common_tags_master = {
    Name = "Master"
    Owner_2 = "bartek"
    Project = "devops_project_aws"
  }
  common_tags_worker = {
    Name = "Worker"
    Owner_2 = "bartek"
    Project = "devops_project_aws"
  }
  ssh_user_master  = "ubuntu"
  key_name_master  = "jenkins"
  ssh_user_worker  = "ubuntu"
  key_name_worker  = "jenkins"
  efs_id           = module.vpc.efs_mount_target_ip
}

resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes_sg"
  vpc_id      = module.vpc.vpc_id
  lifecycle {
    create_before_destroy = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 17900
    to_port     = 17999
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 30000
    to_port     = 35000
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubernetes_sg"
  }
}

resource "tls_private_key" "master" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "master" {
  key_name   = "master-key"
  public_key = tls_private_key.master.public_key_openssh
}

resource "tls_private_key" "worker" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "worker" {
  key_name   = "worker-key"
  public_key = tls_private_key.worker.public_key_openssh
}

resource "aws_instance" "master_instance" {
  count                  = var.ec2_count_master
  ami                    = var.ami_us_east_2_master
  instance_type          = var.ec2_instance_type_master
  iam_instance_profile = module.policy.instance_profile_name
  tags                   = local.common_tags_master
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.master.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  user_data = <<-EOF
                #!/bin/bash
                echo "Dzialaj" >> /home/ubuntu/environment
                echo "EFS_ID=${local.efs_id}" >> /home/ubuntu/environment
              EOF
  
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'Wait for ssh creation'"
    ]
    connection {
      type        = "ssh"
      user        = local.ssh_user_master
      private_key = tls_private_key.master.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "worker_instance" {
  count                  = var.ec2_count_worker
  ami                    = var.ami_us_east_2_worker
  instance_type          = var.ec2_instance_type_worker
  iam_instance_profile = module.policy.instance_profile_name
  tags                   = local.common_tags_worker
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.worker.key_name
  associate_public_ip_address = true
  
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  user_data = <<-EOF
                #!/bin/bash
                echo "EFS_ID=${local.efs_id}" >> /home/ubuntu
              EOF

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'Wait for ssh creation'"
    ]
    connection {
      type        = "ssh"
      user        = local.ssh_user_worker
      private_key = tls_private_key.worker.private_key_pem
      host        = self.public_ip
    }
  }
}
