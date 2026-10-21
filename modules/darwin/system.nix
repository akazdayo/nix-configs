{ hostMeta, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.always-allow-substitutes = true;
  nix.settings.extra-trusted-substituters = [
    "https://cache.lix.systems"
    "https://attic.odango.app/odango"
  ];
  nix.settings.extra-trusted-public-keys = [
    "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    "odango:8blIZl1xfwVCsNo2vUDYP5OXgwWAcC5WJDI1HuoeKLk="
  ];

  nixpkgs.hostPlatform = hostMeta.system;
  environment.systemPath = [ "/opt/homebrew/bin" ];
}
