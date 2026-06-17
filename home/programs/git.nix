{
  lib,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "akazdayo";
        email = "82073147+akazdayo@users.noreply.github.com";
        signingKey = "~/.ssh/id_ed25519_sk_rk.pub";
      };
      init = {
        defaultBranch = "main";
      };
      lfs."customtransfer.xet" = {
        path = "git-xet";
        args = "transfer";
        concurrent = true;
      };
      commit = {
        gpgsign = true;
      };
      gpg = {
        format = "ssh";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        ssh = {
          program = "/opt/homebrew/bin/ssh-keygen";
        };
      };
      core = lib.optionalAttrs pkgs.stdenv.isDarwin {
        sshCommand = "/opt/homebrew/bin/ssh";
      };
    };
  };
}
