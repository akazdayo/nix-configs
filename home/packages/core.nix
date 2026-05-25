{
  pkgs,
  pkgs-unstable,
  lib,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.hostName == "nixos";
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    (with pkgs; [
      comma
      vim
      nixd
      nil
      alejandra
      nixfmt
      fastfetch
      tree
      jq
      wget
      lazygit
      gh
      attic-client
    ])
    ++ lib.optionals isLinux (
      with pkgs;
      [
        starship
        tailscale
      ]
    )
    ++ [
      pkgs-unstable.wakatime-cli
      (if isDesktop then pkgs.btop-cuda else pkgs.btop)
      (if isDesktop then pkgs-unstable.wireguard-tools else pkgs.wireguard-tools)
    ];
}
