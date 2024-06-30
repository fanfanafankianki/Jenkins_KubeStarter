output "jenkins_instance_public_ip" {
  description = "The public IP addresses of the master instances"
  value       = aws_instance.jenkins_instance.public_ip
}

output "jenkins_private_key_pem" {
  value     = tls_private_key.jenkins.private_key_pem
  sensitive = true
}
