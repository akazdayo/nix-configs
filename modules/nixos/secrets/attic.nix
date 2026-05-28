{ ... }:
{
  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
    };

    secrets.atticd-env = {
      sopsFile = ../../../secrets/attic/atticd-env.yaml;
      owner = "root";
      mode = "0400";
    };
  };
}
