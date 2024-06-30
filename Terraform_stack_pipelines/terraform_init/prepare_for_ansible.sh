#!/bin/bash

# Pobierz wartość klucza prywatnego z Terraform output
JENKINS_PRIVATE_KEY=$(terraform output -raw jenkins_private_key_pem)
# Sprawdź, czy komenda terraform output powiodła się
if [ $? -ne 0 ]; then
    echo "Error: Failed to get jenkins_private_key_pem from Terraform output"
    exit 1
fi

# Zapisz klucz prywatny do pliku master.pem
echo "${JENKINS_PRIVATE_KEY}" > Ansible/jenkins.pem

# Ustaw odpowiednie uprawnienia dla pliku klucza prywatnego
chmod 600 Ansible/jenkins.pem

# Wyświetl komunikat o sukcesie
echo "The private key has been saved to Ansible/jenkins.pem"

JENKINS_IP=$(terraform output -raw jenkins_instance_public_ip)

echo "${JENKINS_IP}"

# Zapisz adresy IP do pliku hosts w odpowiednich sekcjach
{
    echo "[jenkins]"
    echo "EC2_JENKINS ansible_host=${JENKINS_IP} ansible_user=ubuntu ansible_ssh_private_key_file=jenkins.pem"
} > Ansible/hosts

# Wyświetl komunikat o sukcesie
echo "Hosts modified properly"
