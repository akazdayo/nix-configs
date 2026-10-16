{
  inputs,
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.platform == "nixos" && hostMeta.role == "desktop";
  # The nixpkgs t3code package otherwise accepts node-pty's upstream
  # prebuilt binary. Force its install script to compile a NixOS-compatible
  # addon, which node-pty prefers from build/Release at runtime.
  t3code = pkgs-unstable.t3code.override {
    t3code-unwrapped = pkgs-unstable.t3code.unwrapped.overrideAttrs (old: {
      preBuild = ''
        node_pty_prebuild="$(find node_modules/.pnpm -path '*/node-pty/scripts/prebuild.js' -print -quit)"
        if [ -z "$node_pty_prebuild" ]; then
          echo "node-pty prebuild script not found" >&2
          exit 1
        fi
        substituteInPlace "$node_pty_prebuild" \
          --replace-fail "process.env.npm_config_build_from_source === 'true'" "true"
      ''
      + (old.preBuild or "");
    });
  };

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
          t3code
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
