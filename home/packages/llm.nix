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

  pi-acp = pkgs-unstable.buildNpmPackage {
    pname = "pi-acp";
    version = "0.0.31";

    src = pkgs-unstable.fetchFromGitHub {
      owner = "svkozak";
      repo = "pi-acp";
      rev = "9e857dcc05a057404eb1537e5f31e5aef88a5863";
      hash = "sha256-bM3V/3fxkY2Ib+OyfT82StIIRSLXGDuYUbt1CZKpTuo=";
    };

    npmDepsHash = "sha256-qN+b/tMbnJLkWjotl3XrA0nfZ3KT/mT6gM+n3Qiz8Wk=";
  };
in
{
  home.packages =
    (
      if isDesktop then
        [
          pkgs-unstable.bubblewrap
          inputs.codex-desktop-linux.packages.${hostMeta.system}.default
          pkgs.lmstudio
        ]
      else
        [ ]
    )
    ++ (with pkgs-with-llm-agents.llm-agents; [
      # LLM Agents from numtide/llm-agents.nix
      opencode2
      # codex
      # codex-acp
      pi
    ])
    ++ [
      # Use upstream's pinned dependencies to match the numtide binary cache.
      inputs.llm-agents.packages.${hostMeta.system}.t3code-desktop
      (pkgs-unstable.writeShellScriptBin "opencode" ''
        exec ${pkgs-with-llm-agents.llm-agents.opencode2}/bin/opencode2 "$@"
      '')
      pi-acp
    ];
}
