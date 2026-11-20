{
  config,
  hostMeta,
  lib,
  pkgs,
  ...
}:
{
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.extended = true;

    sessionVariables = lib.optionalAttrs (hostMeta.platform == "nixos") {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };

    profileExtra = lib.optionalString pkgs.stdenv.isDarwin ''
      if [[ -d /opt/homebrew/bin ]]; then
        path=(/opt/homebrew/bin "$path[@]")
      fi
    '';

    initContent = ''
      path=("$HOME/.bun/bin" "$path[@]")
      PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f %# '
    '';
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
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
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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
}
