module "vpc" {
 source = "./modules/vpc/"
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
}

resource "aws_security_group" "web_sg" {
  name        = var.security_group.sg_name
  vpc_id      = module.vpc.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port   = var.security_group.ssh_port
    to_port     = var.security_group.ssh_port
    protocol    = var.security_group.protocol
    cidr_blocks = var.security_group.cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes_sg"
  vpc_id      = module.vpc.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.security_group.cidr_blocks
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
  #count                  = var.ec2_count
  ami                    = var.ami_us_east_2_master
  instance_type          = var.ec2_instance_type_master
  tags                   = local.common_tags_master
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id, aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.master.key_name
  associate_public_ip_address = true
  
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
  #count                  = var.ec2_count
  ami                    = var.ami_us_east_2_worker
  instance_type          = var.ec2_instance_type_worker
  tags                   = local.common_tags_worker
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id, aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.worker.key_name
  associate_public_ip_address = true
  
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
