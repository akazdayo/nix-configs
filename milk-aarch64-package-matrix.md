# Milk: aarch64-linux パッケージ公開・キャッシュ一覧

- 対象: Milk の host/import module と Home Manager module に明示された package =、environment.systemPackages、home.packages、fonts/Fcitx/graphics/udev/OBS plugin の package/list 要素。
- 除外: 依存パッケージ、NixOS/Home Manager の暗黙の既定パッケージ、生成補助 derivation、Flatpak のアプリ ID。
- 評価: flake.lock の nixpkgs stable（nixos-26.05）、unstable（nixos-unstable）、外部 flake を aarch64-linux として評価。公開=package metadata の meta.platforms に aarch64-linux が含まれること。
- キャッシュ: 2026-09-13 JST に target 出力のストアハッシュの .narinfo を cache.nixos.org、cache.numtide.com、akazdayo-nixos-config.cachix.org へ照会。表の「あり」は少なくとも1つで HTTP 200。
- 集計: 118 件中、aarch64-linux 公開 105 件 / 非公開 13 件、narinfo キャッシュあり 30 件 / なし 88 件。

## aarch64-linux 公開あり

| パッケージ属性             | 指定元 / channel                   | aarch64-linux 公開 |                         キャッシュ |
| -------------------------- | ---------------------------------- | -----------------: | ---------------------------------: |
| vim                        | NixOS module / stable              |               あり |                    cache.nixos.org |
| cloudflared                | NixOS module / unstable            |               あり |                               なし |
| pipewire                   | NixOS module / stable              |               あり |                               なし |
| simple-scan                | NixOS module / stable              |               あり |                               なし |
| sane-airscan               | NixOS module / stable              |               あり |                               なし |
| sane-backends              | NixOS module / stable              |               あり |                    cache.nixos.org |
| mesa                       | NixOS module / stable              |               あり |                               なし |
| egl-wayland                | NixOS module / stable              |               あり |                               なし |
| libva                      | NixOS module / stable              |               あり |                               なし |
| libva-utils                | NixOS module / stable              |               あり |                               なし |
| sbctl                      | NixOS module / stable              |               あり |                               なし |
| age                        | NixOS module / stable              |               あり |                               なし |
| sops                       | NixOS module / stable              |               あり |                               なし |
| ssh-to-age                 | NixOS module / stable              |               あり |                               なし |
| age-plugin-yubikey         | NixOS module / stable              |               あり |                               なし |
| fcitx5-mozc                | NixOS module / stable              |               あり |                               なし |
| fcitx5-skk                 | NixOS module / stable              |               あり |                               なし |
| fcitx5-gtk                 | NixOS module / stable              |               あり |                               なし |
| fcitx5-with-addons         | NixOS module / stable              |               あり |                               なし |
| fcitx5-configtool          | NixOS module / stable              |               あり |                               なし |
| noto-fonts-cjk-sans        | NixOS module / stable              |               あり |                               なし |
| noto-fonts                 | NixOS module / stable              |               あり |                               なし |
| noto-fonts-cjk-serif       | NixOS module / stable              |               あり |                               なし |
| noto-fonts-color-emoji     | NixOS module / stable              |               あり |                               なし |
| inter                      | NixOS module / stable              |               あり |                               なし |
| monaspace                  | NixOS module / stable              |               あり |                               なし |
| nerd-fonts.fira-code       | NixOS module / stable              |               あり |                               なし |
| fira-code                  | NixOS module / stable              |               あり |                               なし |
| nvtopPackages.nvidia       | NixOS module / stable              |               あり |                               なし |
| cudaPackages.cuda_nvcc     | NixOS module / stable              |               あり |                               なし |
| nvidiaPackages.stable      | NixOS module / stable              |               あり |                               なし |
| niri                       | NixOS module / unstable            |               あり |                               なし |
| \_1password-cli            | NixOS module / stable              |               あり |                               なし |
| bubblewrap                 | Home Manager package / unstable    |               あり | cache.nixos.org, cache.numtide.com |
| lmstudio                   | Home Manager package / unstable    |               あり |                               なし |
| prismlauncher              | Home Manager package / stable      |               あり |                    cache.nixos.org |
| alcom                      | Home Manager package / stable      |               あり |                    cache.nixos.org |
| heroic                     | Home Manager package / stable      |               あり |      なし（target 出力を評価不能） |
| wineWow64Packages.stable   | Home Manager package / stable      |               あり |                               なし |
| winetricks                 | Home Manager package / stable      |               あり |                               なし |
| vrcx                       | Home Manager package / stable      |               あり |                               なし |
| wayvr                      | Home Manager package / unstable    |               あり |                    cache.nixos.org |
| bs-manager                 | Home Manager package / unstable    |               あり |      なし（target 出力を評価不能） |
| slimevr                    | Home Manager package / unstable    |               あり |                               なし |
| wl-clipboard               | Home Manager package / stable      |               あり |                    cache.nixos.org |
| xwayland-satellite         | Home Manager package / stable      |               あり |                               なし |
| brightnessctl              | Home Manager package / stable      |               あり |                    cache.nixos.org |
| playerctl                  | Home Manager package / stable      |               あり |                               なし |
| pavucontrol                | Home Manager package / stable      |               あり |                    cache.nixos.org |
| networkmanagerapplet       | Home Manager package / stable      |               あり |                               なし |
| blueman                    | Home Manager package / stable      |               あり |                               なし |
| nwg-look                   | Home Manager package / stable      |               あり |                    cache.nixos.org |
| qt5ct                      | Home Manager package / stable      |               あり |                    cache.nixos.org |
| qt6ct                      | Home Manager package / stable      |               あり |                    cache.nixos.org |
| polkit_gnome               | Home Manager package / stable      |               あり |                               なし |
| dolphin                    | Home Manager package / stable      |               あり |                               なし |
| gimp                       | Home Manager package / stable      |               あり |                               なし |
| kooha                      | Home Manager package / stable      |               あり |                               なし |
| yt-dlp                     | Home Manager package / stable      |               あり |                               なし |
| ffmpeg                     | Home Manager package / stable      |               あり |                               なし |
| vlc                        | Home Manager package / stable      |               あり |                    cache.nixos.org |
| mpvpaper                   | Home Manager package / stable      |               あり |                               なし |
| pnpm                       | Home Manager package / unstable    |               あり | cache.nixos.org, cache.numtide.com |
| xdg-utils                  | Home Manager package / stable      |               あり |                               なし |
| libreoffice                | Home Manager package / stable      |               あり |                               なし |
| signal-desktop             | Home Manager package / stable      |               あり |                               なし |
| mattermost-desktop         | Home Manager package / stable      |               あり |                               なし |
| google-chrome              | Home Manager package / stable      |               あり |                               なし |
| nautilus                   | Home Manager package / stable      |               あり |                    cache.nixos.org |
| unar                       | Home Manager package / stable      |               あり |                               なし |
| obsidian                   | Home Manager package / stable      |               あり |                               なし |
| vesktop                    | Home Manager package / stable      |               あり |                               なし |
| chromium                   | Home Manager package / stable      |               あり |                    cache.nixos.org |
| comma                      | Home Manager package / stable      |               あり |                               なし |
| nixd                       | Home Manager package / stable      |               あり |                               なし |
| nil                        | Home Manager package / stable      |               あり |                               なし |
| alejandra                  | Home Manager package / stable      |               あり |                               なし |
| nixfmt                     | Home Manager package / stable      |               あり |                               なし |
| fastfetch                  | Home Manager package / stable      |               あり |                    cache.nixos.org |
| tree                       | Home Manager package / stable      |               あり |                    cache.nixos.org |
| jq                         | Home Manager package / stable      |               あり |                               なし |
| wget                       | Home Manager package / stable      |               あり |                               なし |
| lazygit                    | Home Manager package / stable      |               あり |                               なし |
| gh                         | Home Manager package / stable      |               あり |                               なし |
| attic-client               | Home Manager package / stable      |               あり |                    cache.nixos.org |
| nmap                       | Home Manager package / stable      |               あり |                               なし |
| dig                        | Home Manager package / stable      |               あり |                               なし |
| starship                   | Home Manager package / stable      |               あり |                    cache.nixos.org |
| tailscale                  | Home Manager package / stable      |               あり |                               なし |
| btop-cuda                  | Home Manager package / stable      |               あり |                               なし |
| wireguard-tools            | Home Manager package / stable      |               あり |                               なし |
| git-xet                    | Home Manager package / unstable    |               あり |                    cache.nixos.org |
| wakatime-cli               | Home Manager package / unstable    |               あり |                               なし |
| grim                       | Home Manager package / stable      |               あり |                    cache.nixos.org |
| adwaita-icon-theme         | Home Manager package / stable      |               あり |                               なし |
| codex-desktop              | Home Manager / LLM / external      |               あり |                               なし |
| wivrn                      | NixOS module / external-overlay    |               あり |                               なし |
| opencode                   | Home Manager / LLM / llm-agents    |               あり |                               なし |
| pi                         | Home Manager / LLM / llm-agents    |               あり |                               なし |
| spade                      | Home Manager / NixVim LSP / stable |               あり |                    cache.nixos.org |
| obs-wlrobs                 | Home Manager / OBS plugin / stable |               あり |                    cache.nixos.org |
| obs-backgroundremoval      | Home Manager / OBS plugin / stable |               あり |                    cache.nixos.org |
| obs-pipewire-audio-capture | Home Manager / OBS plugin / stable |               あり |                    cache.nixos.org |
| obs-gstreamer              | Home Manager / OBS plugin / stable |               あり |                    cache.nixos.org |
| obs-vkcapture              | Home Manager / OBS plugin / stable |               あり |                    cache.nixos.org |

## aarch64-linux 公開なし

| パッケージ属性      | 指定元 / channel                |        aarch64-linux 公開 |                    キャッシュ |
| ------------------- | ------------------------------- | ------------------------: | ----------------------------: |
| nvidia-vaapi-driver | NixOS module / stable           |                      なし |               cache.nixos.org |
| ipafont             | NixOS module / stable           |                      なし |                          なし |
| kochi-substitute    | NixOS module / stable           |                      なし |                          なし |
| nh                  | NixOS module / stable           |                      なし |                          なし |
| zoom-us             | NixOS module / stable           |                      なし |                          なし |
| osu-lazer-bin       | Home Manager package / stable   |                      なし | なし（target 出力を評価不能） |
| protonup-qt         | Home Manager package / stable   |                      なし |                          なし |
| mpv                 | Home Manager package / stable   |                      なし |               cache.nixos.org |
| spotify             | Home Manager package / unstable |                      なし |                          なし |
| unityhub            | Home Manager package / stable   |                      なし |                          なし |
| slack               | Home Manager package / stable   |                      なし | なし（target 出力を評価不能） |
| tor-browser         | Home Manager package / stable   |                      なし | なし（target 出力を評価不能） |
| pi-acp              | Home Manager / LLM / custom     | なし（custom derivation） |     なし（custom derivation） |

注: aarch64 非対応または内部 assert で target 出力を評価できないものは、公開を「なし」とし、キャッシュも「なし」とした。pi-acp はこの flake 内の custom derivation で、公開 nixpkgs package ではないため「なし」とした。
