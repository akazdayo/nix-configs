check "keypair_required" {
  assert {
    condition     = var.keypair_name != "" || var.public_key_path != ""
    error_message = "Either keypair_name or public_key_path must be provided for SSH access."
  }
}

check "floating_ip_pool_required" {
  assert {
    condition     = !var.allocate_floating_ip || var.external_network_name != ""
    error_message = "external_network_name must be set when allocate_floating_ip is true."
  }
}

check "network_required" {
  assert {
    condition     = var.network_name != "" || var.network_id != ""
    error_message = "Either network_name or network_id must be provided."
  }
}

locals {
  extra_tcp_ingress_rules = flatten([
    for rule in var.extra_tcp_ingress_rules : [
      for cidr in rule.cidrs : {
        key  = "${rule.name}-${rule.port}-${cidr}"
        port = rule.port
        cidr = cidr
      }
    ]
  ])
}

data "openstack_networking_network_v2" "network" {
  network_id = var.network_id != "" ? var.network_id : null
  name       = var.network_id == "" ? var.network_name : null
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

resource "openstack_networking_secgroup_rule_v2" "extra_tcp_ingress" {
  for_each = {
    for rule in local.extra_tcp_ingress_rules : rule.key => rule
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
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
  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    ssh_user = var.ssh_user
  })

  network {
    port = openstack_networking_port_v2.port.id
  }

  metadata = var.metadata
  tags     = var.tags

  vendor_options {
    detach_ports_before_destroy = true
  }

  lifecycle {
    ignore_changes = [user_data]
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
