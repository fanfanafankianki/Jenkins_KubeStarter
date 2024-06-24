locals {
  common_tags = {
    Name = "Worker"
    Owner_2 = "bartek"
    Project = "devops_project_aws"
  }
  ssh_user  = "ubuntu"
  key_name  = "jenkins"
}

# Pobranie istniejącej grupy zabezpieczeń na podstawie nazwy
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["Kubernetes_Security_Group"]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "worker" {
  key_name   = "worker-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "/tmp/worker-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "instance" {
  #count                  = var.ec2_count
  ami                    = var.ami_us_east_2
  instance_type          = var.ec2_instance_type
  tags                   = local.common_tags
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  key_name               = aws_key_pair.worker.key_name
  associate_public_ip_address = true
  
  provisioner "remote-exec" {
    inline = [
      "sudo echo 'Wait for ssh creation'"
    ]
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = tls_private_key.example.private_key_pem
      host        = self.public_ip
    }
  }
  provisioner "local-exec" {
    command = <<EOT
      cd ../Ansible_provisioning/worker
      echo '[web_servers]' > hosts
      echo 'EC2_WORKER ansible_host=IP ansible_user=ubuntu' >> hosts 
      sed -i 's/IP/${self.public_ip}/g' hosts
      ansible-playbook -i hosts --private-key ${local_file.private_key.filename} --ssh-extra-args="-o StrictHostKeyChecking=no" provisioning.yaml
      cat hosts
    EOT
  }
}
