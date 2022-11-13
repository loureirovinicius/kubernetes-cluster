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

variable "machine_user" {
  type = string
  default = "ubuntu"
}

variable "machine_names" {
  type    = list(string)
  default = ["master_node", "worker_node_1", "worker_node_2"]
}

variable "key_name" {
  type = string
  default = "instances_key"
}

variable "network_interface_id" {
  type = list(any)
}