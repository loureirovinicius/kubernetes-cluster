locals {
  ports_ingress = {
    "http" : { from_port : 80, to_port : 80 },
    "https" : { from_port : 443, to_port : 443 },
    "ssh" : { from_port : 22, to_port : 22 },
    "api_server" : { from_port : 6443, to_port : 6443 }
    "node_ports" : { from_port : 30000, to_port : 32767 }
  }
}

variable "ip_adresses" {
  type    = list(string)
  default = ["192.168.0.10", "192.168.0.11", "192.168.0.12"]
}