module "vpc" {
 source = "./modules/vpc/"
}

module "ec2_master" {
 source = "./modules/ec2_master/"
 ec2_count         = var.ec2_count                 #PASS INSTANCE COUNT >>> terraform apply -var="ec2_count=2"
 ec2_instance_type = var.ec2_instance_type         #PASS INSTANCE TYPE  >>> terraform apply -var="ec2_instance_type=t2.small"
 public_subnet_ids = module.vpc.public_subnet_ids  #GET VPC OUTPUT AND BASE ON IT
 vpc_id            = module.vpc.vpc_id             #GET VPC OUTPUT AND BASE ON IT
}

module "ec2_worker" {
 source = "./modules/ec2_worker/"
 sg_id             = module.ec2_master.sg_id
 ec2_count         = var.ec2_count                 #PASS INSTANCE COUNT >>> terraform apply -var="ec2_count=2"
 ec2_instance_type = var.ec2_instance_type         #PASS INSTANCE TYPE  >>> terraform apply -var="ec2_instance_type=t2.small"
 public_subnet_ids = module.vpc.public_subnet_ids  #GET VPC OUTPUT AND BASE ON IT
 vpc_id            = module.vpc.vpc_id             #GET VPC OUTPUT AND BASE ON IT
}

module "s3" {
 source = "./modules/s3/"
}

#data "aws_availability_zones" "available" {
#  state = "available"
#}

#output "list_of_az" {
#  value = data.aws_availability_zones.available.names
#}
