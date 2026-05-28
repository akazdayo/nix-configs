variable "instance_name" {
  type        = string
  description = "Name of the OpenStack compute instance"
}

variable "host_name" {
  type        = string
  description = "NixOS flake host output name for nixos-rebuild"
  default     = "openstack"
}

variable "image_id" {
  type        = string
  description = "Glance image UUID for NixOS qcow2"
  default     = "ac5fc61e-258b-4f8b-a06c-229c26f1e38f"
}

variable "flavor_name" {
  type        = string
  description = "OpenStack flavor name (e.g. m1.medium)"
}

variable "network_name" {
  type        = string
  description = "OpenStack network name to attach the port to"
}

variable "network_id" {
  type        = string
  description = "OpenStack network UUID to attach the port to (alternative to network_name)"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Optional subnet UUID for fixed IP allocation"
  default     = ""
}

variable "keypair_name" {
  type        = string
  description = "Existing OpenStack keypair name (preferred; avoids generating private keys in state)"
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key for keypair creation (only used if keypair_name is empty)"
  default     = ""
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed SSH ingress. Use an empty list to avoid exposing SSH."
  default     = []
}

variable "extra_tcp_ingress_rules" {
  type = list(object({
    name  = string
    port  = number
    cidrs = list(string)
  }))
  description = "Additional TCP ingress rules to add to the instance security group"
  default     = []

  validation {
    condition = alltrue([
      for rule in var.extra_tcp_ingress_rules :
      rule.port >= 1 && rule.port <= 65535 && length(rule.cidrs) > 0
    ])
    error_message = "Each extra TCP ingress rule must use a port between 1 and 65535 and at least one CIDR block."
  }
}

variable "allocate_floating_ip" {
  type        = bool
  description = "Whether to allocate and associate a floating IP"
  default     = true
}

variable "external_network_name" {
  type        = string
  description = "External network name for floating IP pool (required if allocate_floating_ip=true)"
  default     = ""
}

variable "metadata" {
  type        = map(string)
  description = "Instance metadata key-value pairs"
  default     = {}
}

variable "tags" {
  type        = list(string)
  description = "Instance tags"
  default     = ["nixos", "openstack"]
}

variable "ssh_user" {
  type        = string
  description = "SSH username for deploy-rs bootstrap access (created by user-data script with NOPASSWD sudo)"
  default     = "deploy"
}
