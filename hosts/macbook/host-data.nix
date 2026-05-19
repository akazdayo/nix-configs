{ hostMeta, ... }:
let
  hostData = {
    ssh.matchBlocks."192.168.11.50" = {
      user = "akazdayo";
      identityFile = "~/.ssh/id_ed25519_sk_rk";
      identityAgent = "none";
    };
  };
in
{
  _module.args.hostData = hostData;

  nix.settings.always-allow-substitutes = true;
  nix.settings.extra-trusted-substituters = [
    "https://cache.lix.systems"
  ];
  nix.settings.extra-trusted-public-keys = [
    "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
  ];

  nixpkgs.hostPlatform = hostMeta.system;

  environment.systemPath = [
    "/opt/homebrew/bin"
  ];

  system.primaryUser = hostMeta.primaryUser;
  system.stateVersion = 6;

  users.users.${hostMeta.primaryUser}.home = "/Users/${hostMeta.primaryUser}";

  environment.variables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
}
