instance_name   = "minecraft"
host_name       = "minecraft"
image_id        = "ac5fc61e-258b-4f8b-a06c-229c26f1e38f"
flavor_name     = "m1.medium"
network_name    = ""
network_id      = "5035c7c8-98dc-4e14-a7f2-c33af3c67c01"
subnet_id       = ""
keypair_name    = "yubikey"
public_key_path = ""

ssh_allowed_cidrs = ["0.0.0.0/0"]

extra_tcp_ingress_rules = [
  {
    name  = "velocity-smp"
    port  = 25566
    cidrs = ["138.252.25.166/32"]
  },
  {
    name  = "velocity-creative"
    port  = 25568
    cidrs = ["138.252.25.166/32"]
  }
]
extra_udp_ingress_rules = [
  {
    name  = "simple-voice-chat"
    port  = 24454
    cidrs = ["138.252.25.166/32"]
  }
]

allocate_floating_ip  = false
external_network_name = ""

metadata = {
  environment = "example"
}

tags = ["nixos", "openstack", "minecraft"]

ssh_user = "deploy"
