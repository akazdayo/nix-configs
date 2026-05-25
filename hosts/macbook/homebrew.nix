{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [ ];
    brews = [
      "openssh"
      "libfido2"
      "ykman"
      "opensc"
    ];
    casks = [
      "vesktop"
      "orbstack"
      "spotify"
      "ghostty"
      "loop"
      "yubico-authenticator"
      "helium-browser"
      "obsidian"
    ];
    masApps = { };
  };
}
