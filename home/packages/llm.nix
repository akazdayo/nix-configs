{
  inputs,
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.platform == "nixos" && hostMeta.role == "desktop";
  agents = inputs.llm-agents.packages.${hostMeta.system};
in
{
  home.packages =
    (if isDesktop then [ pkgs-unstable.bubblewrap ] else [ ])
    ++ (with pkgs-with-llm-agents.llm-agents; [
      opencode2
    ])
    ++ [
      (
        if isDesktop then
          agents.t3code-desktop.override {
            t3code = agents.t3code.override { providerPackages = [ agents.codex ]; };
          }
        else
          agents.t3code-desktop
      )
      agents.codex
      (pkgs-unstable.writeShellScriptBin "opencode" ''
        exec ${pkgs-with-llm-agents.llm-agents.opencode2}/bin/opencode2 "$@"
      '')
    ];
}
