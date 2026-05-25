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
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        signingKey = "~/.ssh/id_ed25519_sk_rk.pub";
      };
      init = {
        defaultBranch = "main";
      };
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      commit = {
        gpgsign = true;
      };
      core = {
        sshCommand = "/opt/homebrew/bin/ssh";
      };
      gpg = {
        format = "ssh";
        ssh = {
          program = "/opt/homebrew/bin/ssh-keygen";
        };
      };
    };
  };
}
