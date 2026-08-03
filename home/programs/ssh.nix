{
  pkgs,
  lib,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        header = "Host github.com";
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_sk_rk";
        IdentityAgent = "none";
        IdentitiesOnly = "yes";
      };
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      "*" = {
        header = "Host *";
        IdentityFile = "~/.ssh/id_ed25519_sk_rk";
        IdentityAgent = "none";
      };
    };
  };
}
