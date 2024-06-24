

locals {
  common_tags = {
    Name = "Master"
    Owner_2 = "bartek"
    Project = "devops_project_aws"
  }
  ssh_user  = "ubuntu"
  key_name  = "jenkins"

}

resource "aws_security_group" "web_sg" {
  name        = var.security_group.sg_name
  vpc_id      = var.vpc_id
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
  vpc_id      = var.vpc_id
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


# resource "tls_private_key" "example" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = tls_private_key.example.public_key_openssh
# }

# resource "local_file" "private_key" {
#   content  = tls_private_key.example.private_key_pem
#   filename = "/tmp/deployer-key.pem"
#   file_permission = "0400"
# }

# resource "aws_instance" "instance" {
#   #count                  = var.ec2_count
#   ami                    = var.ami_us_east_2
#   instance_type          = var.ec2_instance_type
#   tags                   = local.common_tags
#   subnet_id              = var.public_subnet_ids[0]
#   vpc_security_group_ids = [aws_security_group.web_sg.id]
#   key_name               = aws_key_pair.deployer.key_name
#   associate_public_ip_address = true
  
#   provisioner "remote-exec" {
#     inline = [
#       "sudo echo 'Wait for ssh creation'"
#     ]
#     connection {
#       type        = "ssh"
#       user        = local.ssh_user
#       private_key = tls_private_key.example.private_key_pem
#       host        = self.public_ip
#     }
#   }
#   provisioner "local-exec" {
#     command = <<EOT
#       cd ANSIBLE/master
#       sed -i 's/IP/${self.public_ip}/g' hosts
#       ansible-playbook -i hosts --private-key ${local_file.private_key.filename} --ssh-extra-args="-o StrictHostKeyChecking=no" provisioning.yaml
#     EOT
#   }
# }

resource "tls_private_key" "master" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "master" {
  key_name   = "master-key"
  public_key = tls_private_key.master.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.master.private_key_pem
  filename = "/tmp/master-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "instance" {
  #count                  = var.ec2_count
  ami                    = var.ami_us_east_2
  instance_type          = var.ec2_instance_type
  tags                   = local.common_tags
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id, aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.master.key_name
  associate_public_ip_address = true
  
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'Wait for ssh creation'"
    ]
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = tls_private_key.master.private_key_pem
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      cd ../Ansible_provisioning/master
      echo '[web_servers]' > hosts
      echo 'EC2_MASTER ansible_host=IP ansible_user=ubuntu' >> hosts
      cat hosts   
      sed -i 's/IP/${self.public_ip}/g' hosts
      ansible-playbook -i hosts --private-key ${local_file.private_key.filename} --ssh-extra-args="-o StrictHostKeyChecking=no" provisioning.yaml
    EOT
  }
}
