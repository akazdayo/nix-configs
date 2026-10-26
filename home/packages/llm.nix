{
  inputs,
  pkgs,
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.platform == "nixos" && hostMeta.role == "desktop";
in
{
  home.packages =
    (
      if isDesktop then
        [
          pkgs-unstable.bubblewrap
          pkgs.lmstudio
        ]
      else
        [ ]
    )
    ++ (with pkgs-with-llm-agents.llm-agents; [
      opencode2
    ])
    ++ [
      # Use upstream's pinned dependencies to match the numtide binary cache.
      inputs.llm-agents.packages.${hostMeta.system}.t3code-desktop
      (pkgs-unstable.writeShellScriptBin "opencode" ''
        exec ${pkgs-with-llm-agents.llm-agents.opencode2}/bin/opencode2 "$@"
      '')
    ];
}
