variable "aws_keys" {
  type = object({
    access_key = string,
    secret_key = string
  })
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "master_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "worker_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_username" {
  type    = string
  default = "ubuntu"
}

variable "ami" {
  type    = string
  default = "ami-052efd3df9dad4825"
}

variable "machine_names" {
  type    = list(string)
  default = ["master_node", "worker_node_1", "worker_node_2"]
}

variable "ip_adresses" {
  type    = list(string)
  default = ["192.168.0.10", "192.168.0.11", "192.168.0.12"]
}

variable "ssh_key_name" {
  type    = string
  default = "instances_key"
}

locals {
  ports_ingress = {
    "http" : { from_port : 80, to_port : 80 },
    "https" : { from_port : 443, to_port : 443 },
    "ssh" : { from_port : 22, to_port : 22 },
    "api_server" : { from_port : 6443, to_port : 6443 }
    "node_ports" : { from_port : 30000, to_port : 32767 }
  }
}