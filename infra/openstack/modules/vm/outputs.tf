output "instance_id" {
  description = "OpenStack compute instance ID"
  value       = openstack_compute_instance_v2.instance.id
  sensitive   = false
}

output "fixed_ip" {
  description = "First fixed IP allocated to the instance port"
  value       = openstack_networking_port_v2.port.all_fixed_ips[0]
  sensitive   = false
}

output "floating_ip" {
  description = "Floating IP associated with the instance, or null if disabled"
  value       = var.allocate_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : null
  sensitive   = false
}

output "ssh_host" {
  description = "Host to use for SSH access: floating IP if available, otherwise fixed IP"
  value       = var.allocate_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : openstack_networking_port_v2.port.all_fixed_ips[0]
  sensitive   = false
}
