instance_name   = "bluemap"
host_name       = "bluemap"
image_id        = "ac5fc61e-258b-4f8b-a06c-229c26f1e38f"
flavor_name     = "m1.small"
network_name    = ""
network_id      = "5035c7c8-98dc-4e14-a7f2-c33af3c67c01"
subnet_id       = ""
keypair_name    = "yubikey"
public_key_path = ""

ssh_allowed_cidrs = ["0.0.0.0/0"]

extra_tcp_ingress_rules = [
  {
    name  = "bluemap-http-from-gateway"
    port  = 80
    cidrs = ["138.252.25.166/32"]
  },
  {
    name  = "bluemap-rsync-from-minecraft"
    port  = 873
    cidrs = ["138.252.25.159/32"]
  }
]
extra_udp_ingress_rules = []

allocate_floating_ip  = false
external_network_name = ""

metadata = {
  environment = "example"
}

tags = ["nixos", "openstack", "bluemap"]

ssh_user = "deploy"

data_volume_name    = "bluemap-data"
data_volume_size_gb = 20
data_volume_type    = ""
