# Deploy a non-production Kubernetes cluster for studies, tests and whatever is your necessity

The purpose of this project is to deploy a k8s cluster on AWS (or any other cloud provider, if you are familiar with Terraform) using IaC tools, like Ansible and Terraform.
Currently, it works only on Debian-based distros, but I'm looking forward to making it more embracing. ;)

## This project consists of:

### Ansible Roles:
 - Containerd: this role is responsible for installing and enabling containerd on all instances provisioned by Terraform.
 - Kubernetes Master: once containerd is enabled, this role is executed and tools like kubeadm, kubectl and kubelet are installed on instances responsible for being the control plane. It also initiates the control plane and gets the join command for further use of workers.
 - Kubernetes Worker: here all the necessary components are installed and enabled on instances specified as workers in the inventory file. This role also executes a task for joining the cluster.
 
### Terraform files:
For now, every resource is written in the "main.tf" file, but I'm also looking forward to modularizing it for a better understanding.<br>
Except for the access and secret keys, every variable has a default value, but feel free to change it or add more values according to your knowledge.

**Attention**: by default, I used every first index of a list for the master node configuration (like in the "machine_names" variable), but you can change it if needed.

## Setting up and running it:

1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html);

2. Get your [AWS secret and access key](https://aws.amazon.com/pt/blogs/security/wheres-my-secret-access-key/);

3. Cd into *terraform* directory;

4. Open the *terraform.tfvars* file and paste the access and secret keys on their respective fields;

5. Change any configuration according to your necessity; (optional)

6. Run *terraform init* and awaits its completion;

7. Run *terraform plan* and check if everything is alright;

8. Run *terraform apply* if everything is fine and awaits its completion;

9. SSH into your machines. Ex.:
`ssh -i "instance_key.pem" <username>@<public_ip/dns>`;

10. Change to "kube" user with `sudo su kube` command;

11. Run your k8s resources. Ex.: `kubectl run nginx --image nginx --port 80`

12. Enjoy it! :)