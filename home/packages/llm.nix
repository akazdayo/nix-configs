{
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.hostName == "nixos";
  # nixpkgs-unstable の lmstudio 0.4.15-2 は起動時に V8 snapshot エラーになるため、
  # 動作確認済みの 0.4.16-2 を直接指定する。
  lmstudio = pkgs-unstable.lmstudio.override {
    version = "0.4.16-2";
    url = "https://installers.lmstudio.ai/linux/x64/0.4.16-2/LM-Studio-0.4.16-2-x64.AppImage";
    hash = "sha256-faLtj/9M59KRdEMHHgTCPLG4Gl5C7hkdAgmaS/O5rOk=";
  };
in
{
  home.packages =
    (
      if isDesktop then
        [
          lmstudio
        ]
      else
        [ ]
    )
    ++ (with pkgs-with-llm-agents.llm-agents; [
      # LLM Agents from numtide/llm-agents.nix
      opencode
      codex
      claude-code
    ]);
}
