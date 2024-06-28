#!/bin/bash

# Pobierz wartość klucza prywatnego z Terraform output
MASTER_PRIVATE_KEY=$(terraform output -raw master_private_key_pem)
# Sprawdź, czy komenda terraform output powiodła się
if [ $? -ne 0 ]; then
    echo "Error: Failed to get master_private_key_pem from Terraform output"
    exit 1
fi

WORKER_PRIVATE_KEY=$(terraform output -raw worker_private_key_pem)
# Sprawdź, czy komenda terraform output powiodła się
if [ $? -ne 0 ]; then
    echo "Error: Failed to get worker_private_key_pem from Terraform output"
    exit 1
fi

# Zapisz klucz prywatny do pliku master.pem
echo "${MASTER_PRIVATE_KEY}" > Ansible_provisioning/master/master.pem
echo "${WORKER_PRIVATE_KEY}" > Ansible_provisioning/master/worker.pem

# Ustaw odpowiednie uprawnienia dla pliku klucza prywatnego
chmod 600 Ansible_provisioning/master/master.pem
chmod 600 Ansible_provisioning/master/worker.pem

# Wyświetl komunikat o sukcesie
echo "The private key has been saved to Ansible_provisioning/master/master.pem"
echo "The private key has been saved to Ansible_provisioning/master/worker.pem"

MASTER_IPS=$(terraform output -json master_instance_public_ip | jq -r '.[]')
WORKER_IPS=$(terraform output -json worker_instance_public_ip | jq -r '.[]')

echo "${MASTER_IPS}"
echo "${WORKER_IPS}"


# Zapisz adresy IP do pliku hosts w odpowiednich sekcjach
{
    echo "[master]"
    master_count=0
    for ip in $MASTER_IPS; do
        echo "EC2_MASTER_${master_count} ansible_host=${ip} ansible_user=ubuntu ansible_ssh_private_key_file=master.pem"
        master_count=$((master_count + 1))
    done

    echo
    echo "[worker]"
    worker_count=0
    for ip in $WORKER_IPS; do
        echo "EC2_WORKER_${worker_count} ansible_host=${ip} ansible_user=ubuntu ansible_ssh_private_key_file=worker.pem"
        worker_count=$((worker_count + 1))
    done
} > Ansible_provisioning/master/hosts

# Wyświetl komunikat o sukcesie
echo "Hosts modified properly"
