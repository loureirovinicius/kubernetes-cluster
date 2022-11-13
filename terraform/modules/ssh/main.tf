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