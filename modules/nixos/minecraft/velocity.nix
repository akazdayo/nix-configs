{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.local.minecraft.velocity;
  proxyPort = toString cfg.serverPort;
  voiceChatPort = cfg.voiceChatPort;
  minecraftInternalIp = cfg.internalIp;
  smpPort = toString cfg.smpPort;
  creativePort = toString cfg.creativePort;
  primaryInterface = cfg.primaryInterface;
  discordIntegrationVelocity = pkgs.fetchurl {
    url = "https://github.com/zunoser/discord-integration-velocity/releases/download/v1.0.2/discord-integration-velocity-1.0.2.jar";
    sha256 = "b574c60fbcecf0b2e3eba94ed007acaa6b1bf761807a8bebdef9e0e0e7d98923";
  };
  discordIntegrationConfig =
    (import ./discord-integration.nix { inherit config; }).discordIntegrationConfig;
in
{
  imports = [ inputs.minecraft-nix.nixosModules.minecraft-servers ];

  options.local.minecraft.velocity = lib.mkOption { type = lib.types.attrs; };

  config = {
    nixpkgs.overlays = [ inputs.minecraft-nix.overlay ];

    sops = {
      secrets.velocity-forwarding-secret = {
        sopsFile = cfg.sopsFile;
        owner = config.services.minecraft-servers.user or "minecraft";
        mode = "0400";
      };
      secrets.discord-token = {
        sopsFile = cfg.sopsFile;
        owner = config.services.minecraft-servers.user or "minecraft";
        mode = "0400";
      };
      secrets.discord-channel-id = {
        sopsFile = cfg.sopsFile;
        owner = config.services.minecraft-servers.user or "minecraft";
        mode = "0400";
      };

      # Generated at activation time with the decrypted forwarding secret.
      templates = {
        "velocity.toml" = {
          content = ''
            config-version = "2.8"
            bind = "0.0.0.0:${proxyPort}"
            motd = "<red>n<gold>a<yellow>k<green>a<aqua>s<blue>y<light_purple>o<red>u <gold>b<yellow>a<green>k<aqua>e<blue>r<light_purple>y <red>M<gold>i<yellow>n<green>e<aqua>c<blue>r<light_purple>a<red>f<gold>t <yellow>S<green>e<aqua>r<blue>v<light_purple>e<red>r"
            show-max-players = 500
            sample-players-in-ping = true
            online-mode = true
            player-info-forwarding-mode = "modern"
            forwarding-secret-file = "${config.sops.secrets.velocity-forwarding-secret.path}"

            [servers]
            smp = "${minecraftInternalIp}:${smpPort}"
            creative = "${minecraftInternalIp}:${creativePort}"
            try = ["smp"]

            [forced-hosts]

            [advanced]
            compression-level = 1
          '';
          owner = config.services.minecraft-servers.user or "minecraft";
          mode = "0400";
        };

        "discord-integration-velocity-config.json" = {
          content = builtins.toJSON discordIntegrationConfig;
          owner = config.services.minecraft-servers.user or "minecraft";
          mode = "0400";
        };
      };
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;

      servers.velocity = {
        enable = true;
        autoStart = true;

        package = pkgs.velocityServers.velocity;
        jvmOpts = cfg.jvmOpts;

        # Velocity uses "end" rather than "stop" to shut down cleanly
        stopCommand = "end";

        # Velocity does not use Minecraft server.properties
        serverProperties = { };

        # Velocity config copied from sops-nix template at activation time.
        # Must use `files` (not `symlinks`) so Velocity can write back to
        # velocity.toml during config migration (e.g., legacy forwarding-secret
        # → forwarding.secret file in Velocity 3.5.0+).
        # `files` creates a writable copy; cleaned on service stop.
        files = {
          "velocity.toml" = config.sops.templates."velocity.toml".path;
          "plugins/discordintegrationvelocity/config.json" =
            config.sops.templates."discord-integration-velocity-config.json".path;
        };

        symlinks."plugins/discord-integration-velocity-1.0.2.jar" = discordIntegrationVelocity;
      };
    };

    systemd.services.minecraft-server-velocity = {
      restartTriggers = [
        config.sops.templates."velocity.toml".content
        config.sops.templates."discord-integration-velocity-config.json".content
      ];
    };

    networking = {
      firewall.allowedUDPPorts = [ voiceChatPort ];

      nat = {
        enable = true;
        externalInterface = primaryInterface;
        forwardPorts = [
          {
            sourcePort = voiceChatPort;
            destination = "${minecraftInternalIp}:${toString voiceChatPort}";
            proto = "udp";
          }
        ];
      };
    };
  };
}
