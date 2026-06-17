output "instance_id" {
  description = "OpenStack compute instance ID"
  value       = module.vm.instance_id
  sensitive   = false
}

output "fixed_ip" {
  description = "First fixed IP allocated to the instance port"
  value       = module.vm.fixed_ip
  sensitive   = false
}

output "floating_ip" {
  description = "Floating IP associated with the instance, or null if disabled"
  value       = module.vm.floating_ip
  sensitive   = false
}

output "ssh_host" {
  description = "Host to use for SSH access: floating IP if available, otherwise fixed IP"
  value       = module.vm.ssh_host
  sensitive   = false
}

output "data_volume_id" {
  description = "Cinder volume ID for persistent Minecraft server data"
  value       = openstack_blockstorage_volume_v3.minecraft_data.id
  sensitive   = false
}
