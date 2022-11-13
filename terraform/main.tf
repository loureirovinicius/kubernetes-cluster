module "aws_vpc" {
  source = "./modules/vpc"
}

module "ssh" {
  source = "./modules/ssh"
}

module "aws_ec2" {
  source = "./modules/ec2"

  key_name = module.ssh.key_name
  network_interface_id = module.aws_vpc.network_interface_id
}