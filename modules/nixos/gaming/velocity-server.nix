{
  inputs,
  hostMeta,
  pkgs,
  config,
  ...
}:
let
  velocityData = hostMeta.hostData.velocity or { };
  minecraftData = hostMeta.hostData.minecraft or { };

  proxyPort = toString (velocityData.serverPort or 25565);
  voiceChatPort = velocityData.voiceChatPort or 24454;
  minecraftInternalIp =
    minecraftData.internalIp or (throw "hostData.minecraft.internalIp must be set");
  smpPort = toString (minecraftData.smp.serverPort or 25566);
  creativePort = toString (minecraftData.creative.serverPort or 25568);
  primaryInterface =
    hostMeta.hostData.networking.primaryInterface
      or (throw "hostData.networking.primaryInterface must be set");
in
{
  imports = [ inputs.minecraft-nix.nixosModules.minecraft-servers ];

  nixpkgs.overlays = [ inputs.minecraft-nix.overlay ];

  sops = {
    secrets.velocity-forwarding-secret = {
      sopsFile = ../../../secrets/openstack/gateway/velocity.yaml;
      owner = config.services.minecraft-servers.user or "minecraft";
      mode = "0400";
    };

    # Generated at activation time with the decrypted forwarding secret.
    templates."velocity.toml" = {
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
  };

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.velocity = {
      enable = true;
      autoStart = true;

      package = pkgs.velocityServers.velocity;
      jvmOpts = velocityData.jvmOpts or "-Xms512M -Xmx1G";

      # Velocity uses "end" rather than "stop" to shut down cleanly
      stopCommand = "end";

      # Velocity does not use Minecraft server.properties
      serverProperties = { };

      # Velocity config copied from sops-nix template at activation time.
      # Must use `files` (not `symlinks`) so Velocity can write back to
      # velocity.toml during config migration (e.g., legacy forwarding-secret
      # → forwarding.secret file in Velocity 3.5.0+).
      # `files` creates a writable copy; cleaned on service stop.
      files."velocity.toml" = config.sops.templates."velocity.toml".path;
    };
  };

  systemd.services.minecraft-server-velocity.restartTriggers = [
    config.sops.templates."velocity.toml".content
  ];

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
}
