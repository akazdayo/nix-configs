{ ... }:
{
  _module.args.hostData = { };
  nix.settings.extra-substituters = [
    "https://cache.numtide.com"
    "https://akazdayo-nixos-config.cachix.org"
  ];
  nix.settings.extra-trusted-public-keys = [
    "main:p1I0gblo5KOxd64LCmeOmENhGx/fRCVp5CS4aOQGY6w="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    "akazdayo-nixos-config.cachix.org-1:beIgz4A31qNo0DBTEaTGbNy/xGuNJZZpH0n3BDc+JVk="
  ];
}
