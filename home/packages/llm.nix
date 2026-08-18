{
  inputs,
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.platform == "nixos" && hostMeta.role == "desktop";
  # nixpkgs-unstable の lmstudio 0.4.15-2 は起動時に V8 snapshot エラーになるため、
  # 動作確認済みの 0.4.16-2 を直接指定する。

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
          pkgs-unstable.lmstudio
        ]
      else
        [ ]
    )
    ++ (with pkgs-with-llm-agents.llm-agents; [
      # LLM Agents from numtide/llm-agents.nix
      opencode
      # codex
      # codex-acp
      pi
    ])
    ++ [
      pi-acp
    ];
}
