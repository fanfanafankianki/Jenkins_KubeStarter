#PREREQUISUITES
# SET AWS CLI
# terraform init


# PARAMETERS
# ec2_count default value         = 1
# ec2_instance_type default value = t2.micro

########  HOW TO RUN TERRAFORM ########

#1) WITHOUT PARAMETERS WITH DEFAULT VALUES
## terraform apply

#2) WITH PASSED PARAMETER ec2_count and DEFAULT VALUE ec2_instance_type 
## terraform apply -var="ec2_count=2"

#3) WITH PASSED PARAMETER ec2_instance_type and DEFAULT VALUE ec2_count
## terraform apply -var="ec2_instance_type=t3.large"

#4)WITH PASSED BOTH PARAMETERS
## terraform apply -var="ec2_count=2" -var="ec2_instance_type=t3.small"
 


## Jesli na instancji JENKINS mam stara wersje ANSIBLE np ansible --version 2.9 to zainstaluj nowa po wczesniejszej dezinstalacji
##



## sudo apt remove ansible
## sudo apt --purge autoremove
## sudo apt-add-repository ppa:ansible/ansible
## sudo pip3 uninstall ansible
## sudo pip3 uninstall ansible-base
## sudo pip3 uninstall ansible-core
## sudo pip3 install ansible==9.6.0  >> ansible --version  >> powinno pokazac core 2.16