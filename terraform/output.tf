output "region" {
  value = "Your region is: ${var.region}"
}

output "master_instance_type" {
  value = "Master node instance type is: ${var.master_instance_type}"
}

output "worker_instance_type" {
  value = "Worker nodes instance type is: ${var.worker_instance_type}"
}

output "ami_and_user" {
  value = "The chosen AMI is '${var.ami}' and its default user is '${var.instance_username}'"
}

output "instances_public_dns" {
  value = [
    for instance in aws_instance.nodes : "${instance.tags_all.Name}: ${instance.public_dns}"
  ]
}