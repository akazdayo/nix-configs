module "vm" {
  source = "../modules/vm"

  instance_name           = var.instance_name
  host_name               = var.host_name
  image_id                = var.image_id
  flavor_name             = var.flavor_name
  network_name            = var.network_name
  network_id              = var.network_id
  subnet_id               = var.subnet_id
  keypair_name            = var.keypair_name
  public_key_path         = var.public_key_path
  ssh_allowed_cidrs       = var.ssh_allowed_cidrs
  extra_tcp_ingress_rules = var.extra_tcp_ingress_rules
  extra_udp_ingress_rules = var.extra_udp_ingress_rules
  allocate_floating_ip    = var.allocate_floating_ip
  external_network_name   = var.external_network_name
  metadata                = var.metadata
  tags                    = var.tags
  ssh_user                = var.ssh_user
}

resource "openstack_blockstorage_volume_v3" "minecraft_data" {
  name        = var.data_volume_name
  description = "Persistent Minecraft server data for ${var.instance_name}"
  size        = var.data_volume_size_gb
  volume_type = var.data_volume_type != "" ? var.data_volume_type : null

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "minecraft_data" {
  instance_id = module.vm.instance_id
  volume_id   = openstack_blockstorage_volume_v3.minecraft_data.id
}
