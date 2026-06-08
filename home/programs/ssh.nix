{
  pkgs,
  lib,
  hostMeta,
  ...
}:
let
  hostData = hostMeta.hostData;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks =
      (hostData.ssh.matchBlocks or { })
      // {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519_sk_rk";
          identityAgent = "none";
          identitiesOnly = true;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        "*" = lib.hm.dag.entryAfter [ "github.com" ] {
          identityFile = "~/.ssh/id_ed25519_sk_rk";
          identityAgent = "none";
        };
      };
  };
}
