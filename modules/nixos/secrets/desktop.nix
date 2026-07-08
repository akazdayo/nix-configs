{ hostMeta, pkgs, ... }:
let
  primaryUser = hostMeta.primaryUser;
in
{
  services.pcscd.enable = true;

  environment.variables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
  environment.variables.SOPS_AGE_KEY_CMD = "$HOME/.config/sops/age/yubikey-priority.sh";

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
    age
    sops
    ssh-to-age
  ];

  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = false;
      plugins = with pkgs; [ age-plugin-yubikey ];
    };

    secrets.wakatime-api-key = {
      sopsFile = ../../../secrets/milk/wakatime.yaml;
      key = "api-key";
      owner = primaryUser;
      mode = "0400";
    };
  };
}
