{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    #configFile.source = ../../dotfiles/config.nu;
    #envFile.source = ../../dotfiles/env.nu;
    extraConfig = ''
      ${builtins.readFile ../../dotfiles/config.nu}
    '';
    extraEnv = ''
      ${
        if pkgs.stdenv.isDarwin then
          ''
            if ("/opt/homebrew/bin" | path exists) {
              $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")
            }
          ''
        else
          ""
      }
      ${builtins.readFile ../../dotfiles/env.nu}

      # sops YubiKey-priority age identity provider
      $env.SOPS_AGE_KEY_CMD = ($env.HOME | path join '.config' 'sops' 'age' 'yubikey-priority.sh')
    '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {

    };
  };

  programs.direnv = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin then
        pkgs.direnv.overrideAttrs (_: {
          doCheck = false;
        })
      else
        pkgs.direnv;
    enableNushellIntegration = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.fzf = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.ripgrep-all = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";
  };
}
