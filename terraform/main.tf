resource "aws_vpc" "cluster_network" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k8s_cluster_vpc"
  }
}

resource "aws_internet_gateway" "cluster_gateway" {
  vpc_id = aws_vpc.cluster_network.id
  tags = {
    Name = "k8s_cluster_gateway"
  }
}

resource "aws_subnet" "cluster_subnet" {
  vpc_id                  = aws_vpc.cluster_network.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s_cluster_subnet"
  }
}

resource "aws_route_table" "cluster_route_table" {
  vpc_id = aws_vpc.cluster_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.cluster_subnet.id
  route_table_id = aws_route_table.cluster_route_table.id
}

resource "aws_security_group" "cluster_security_group" {
  name        = "k8s_security_group"
  description = "Allowed protocols and ports."
  vpc_id      = aws_vpc.cluster_network.id

  dynamic "ingress" {
    for_each = local.ports_ingress
    content {
      cidr_blocks = ["0.0.0.0/0"]
      description = "${ingress.key} connection"
      from_port   = ingress.value.from_port
      protocol    = "tcp"
      to_port     = ingress.value.to_port
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "ssh_key_content" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_ssh_key" {
  key_name   = var.ssh_key_name
  public_key = trimspace(tls_private_key.ssh_key_content.public_key_openssh)

  provisioner "local-exec" {
    command = <<-EOT
        echo '${tls_private_key.ssh_key_content.private_key_pem}' > ../ansible/'${var.ssh_key_name}'.pem
        chmod 400 ../ansible/'${var.ssh_key_name}'.pem
        EOT
  }
}

resource "aws_network_interface" "cluster_instances_eni" {
  subnet_id       = aws_subnet.cluster_subnet.id
  count           = length(var.ip_adresses)
  private_ips     = [var.ip_adresses[count.index]]
  security_groups = [aws_security_group.cluster_security_group.id]
}

resource "aws_instance" "nodes" {
  ami           = var.ami
  instance_type = var.machine_names[count.index] == "master_node" ? var.master_instance_type : var.worker_instance_type
  count         = length(var.machine_names)
  key_name      = aws_key_pair.cluster_ssh_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.cluster_instances_eni[count.index].id
    device_index         = 0
  }

  tags = {
    Name : var.machine_names[count.index]
  }
}

resource "time_sleep" "await_instance_creation" {
  depends_on = [
    aws_instance.nodes
  ]

  create_duration = "30s"
}

resource "null_resource" "ssh_authorization_procedure" {
  count = length(var.machine_names)
  depends_on = [
    time_sleep.await_instance_creation
  ]

  provisioner "local-exec" {
    command     = "ssh-keyscan -H '${aws_instance.nodes[count.index].public_dns}' >> ~/.ssh/known_hosts"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "local_file" "inventory_creation" {
  content = templatefile("terraform.tftpl", { content = tomap({
    for instance in aws_instance.nodes :
    instance.tags.Name => instance.public_dns
    })
    username = var.instance_username
  })
  filename = "../ansible/inventory.yaml"

  depends_on = [
    null_resource.ssh_authorization_procedure
  ]

  # Ansible playbook execution
  provisioner "local-exec" {
    command     = <<-EOT
    ansible-playbook ../ansible/playbook.yaml -i ../ansible/inventory.yaml --private-key ../ansible/${aws_key_pair.cluster_ssh_key.key_name}.pem -e "master_node_name=${var.machine_names[0]}"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}