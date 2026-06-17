{
  pkgs,
  lib,
  hostMeta,
  ...
}:
let
  hostData = hostMeta.hostData;

  # Convert legacy host-data match block to new settings entry
  toSettingsEntry =
    host: data:
    lib.filterAttrs (_: v: v != null) {
      header = "Host ${host}";
      HostName = data.hostname or null;
      User = data.user or null;
      IdentityFile = data.identityFile or null;
      IdentityAgent = data.identityAgent or null;
    };

  hostEntries = lib.mapAttrs toSettingsEntry (hostData.ssh.matchBlocks or { });
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings =
      hostEntries
      // {
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
