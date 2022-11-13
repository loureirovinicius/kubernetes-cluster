output "network_interface_id" {
  value = [
    for network_interface in aws_network_interface.cluster_instances_eni : network_interface.id 
  ]
}