resource "aws_instance" "nodes" {
  ami           = var.ami
  instance_type = var.machine_names[count.index] == "master_node" ? var.master_instance_type : var.worker_instance_type
  count         = length(var.machine_names)
  key_name      = var.key_name

  network_interface {
    network_interface_id = var.network_interface_id[count.index]
    device_index         = 0
  }

  tags = {
    Name : var.machine_names[count.index]
  }
}

resource "null_resource" "ssh_authorization_procedure" {
  count = length(var.machine_names)

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = aws_instance.nodes[count.index].public_dns
      user = var.machine_user
      private_key = file("../ansible/${var.key_name}.pem")
    }

    inline = ["echo 'Instance ready!'"]
  }

  provisioner "local-exec" {
    command     = "ssh-keyscan -H '${aws_instance.nodes[count.index].public_ip}' >> ~/.ssh/known_hosts"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "local_file" "inventory_creation" {
  content = templatefile("terraform.tftpl", { content = tomap({
    for instance in aws_instance.nodes :
    instance.tags.Name => instance.public_ip
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
    ansible-playbook ../ansible/playbook.yaml -i ../ansible/inventory.yaml --private-key ../ansible/${var.key_name}.pem -e "master_node_name=${var.machine_names[0]}"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}