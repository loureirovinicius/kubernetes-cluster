resource "aws_vpc" "cluster_network" {
  cidr_block           = "192.168.0.0/16"
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

resource "aws_network_interface" "cluster_instances_eni" {
  subnet_id       = aws_subnet.cluster_subnet.id
  count           = length(var.ip_adresses)
  private_ips     = [var.ip_adresses[count.index]]
  security_groups = [aws_security_group.cluster_security_group.id]
}