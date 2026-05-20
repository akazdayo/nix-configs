data "openstack_networking_network_v2" "network" {
  name = var.network_name
}

data "openstack_compute_keypair_v2" "existing" {
  count = var.keypair_name != "" ? 1 : 0
  name  = var.keypair_name
}

resource "openstack_compute_keypair_v2" "imported" {
  count      = var.keypair_name == "" && var.public_key_path != "" ? 1 : 0
  name       = "${var.instance_name}-keypair"
  public_key = file(var.public_key_path)
}

resource "openstack_networking_secgroup_v2" "sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ingress" {
  count = length(var.ssh_allowed_cidrs)

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidrs[count.index]
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_port_v2" "port" {
  name               = "${var.instance_name}-port"
  network_id         = data.openstack_networking_network_v2.network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.sg.id]

  dynamic "fixed_ip" {
    for_each = var.subnet_id != "" ? [1] : []
    content {
      subnet_id = var.subnet_id
    }
  }
}

resource "openstack_compute_instance_v2" "instance" {
  name         = var.instance_name
  image_id     = var.image_id
  flavor_name  = var.flavor_name
  key_pair     = var.keypair_name != "" ? data.openstack_compute_keypair_v2.existing[0].name : (var.public_key_path != "" ? openstack_compute_keypair_v2.imported[0].name : null)
  config_drive = true
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    host_name  = var.host_name
    config_ref = var.config_ref
    ssh_user   = var.ssh_user
  })

  network {
    port = openstack_networking_port_v2.port.id
  }

  metadata = var.metadata
  tags     = var.tags

  vendor_options {
    detach_ports_before_destroy = true
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.allocate_floating_ip ? 1 : 0
  pool  = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count       = var.allocate_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  port_id     = openstack_networking_port_v2.port.id
}
