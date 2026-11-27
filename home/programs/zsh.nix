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
      ZSH_AUTOSUGGEST_MANUAL_REBIND=1

      autoload -Uz add-zsh-hook
      function set_directory_prompt() {
        local git_root git_branch branch_label="" prompt_path='%~'
        if git_root=$(command git rev-parse --show-toplevel 2>/dev/null); then
          local current_dir="''${PWD:A}"
          prompt_path="''${git_root:t}''${current_dir#"$git_root"}"
          prompt_path="''${prompt_path//\%/%%}"
          if git_branch=$(command git symbolic-ref --quiet HEAD 2>/dev/null); then
            git_branch="''${git_branch#refs/heads/}"
            branch_label=" (''${git_branch//\%/%%})"
          fi
        fi
        PROMPT="%F{cyan}%n@%m%f %F{blue}$prompt_path%f$branch_label %# "
      }
      add-zsh-hook precmd set_directory_prompt
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
