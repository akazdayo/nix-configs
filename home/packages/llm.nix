{
  pkgs-unstable,
  pkgs-with-llm-agents,
  hostMeta,
  ...
}:
let
  isDesktop = hostMeta.hostName == "nixos";
  lmstudio = pkgs-unstable.lmstudio.overrideAttrs (old: {
    buildCommand =
      builtins.replaceStrings
        [
          "/usr/share/icons/hicolor/0x0/apps/lm-studio.png"
          "install -m 755 "
          "patchelf --set-interpreter "
        ]
        [
          "/resources/app/.webpack/Icon-512x512.png"
          "true # install -m 755 "
          "true # patchelf --set-interpreter "
        ]
        old.buildCommand;
  });
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
