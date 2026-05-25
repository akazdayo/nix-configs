{
  pkgs,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.hostName == "nixos";
in
{
  home.packages =
    (
      if isDesktop then
        with pkgs;
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
