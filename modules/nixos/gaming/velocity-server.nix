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
  simpleVoiceChatVelocityPlugin = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/ES87t4lm/voicechat-velocity-2.6.18.jar";
    sha512 = "ca8238c3f4d8c0f023912373f6dfe932961fcd83b061c70941b83cf29421d969c65d1771a4ebd7d1e5804057ae8fb92069fbc64a8e66668da119033e0e7ac3cf";
  };
  voiceChatProxyConfig = pkgs.writeText "voicechat-proxy.properties" ''
    # Keep the public voice chat endpoint on the existing gateway UDP port.
    port=${toString voiceChatPort}
    bind_address=
    voice_host=
  '';
  minecraftInternalIp =
    minecraftData.internalIp or (throw "hostData.minecraft.internalIp must be set");
  smpPort = toString (minecraftData.smp.serverPort or 25566);
  creativePort = toString (minecraftData.creative.serverPort or 25568);
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
        motd = "&#x00a7bNixOS Minecraft Network"
        show-max-players = 500
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

      symlinks."plugins/voicechat-velocity.jar" = simpleVoiceChatVelocityPlugin;
      files."plugins/voicechat/voicechat-proxy.properties" = voiceChatProxyConfig;
    };
  };

  systemd.services.minecraft-server-velocity.restartTriggers = [
    config.sops.templates."velocity.toml".content
    voiceChatProxyConfig
    simpleVoiceChatVelocityPlugin
  ];

  networking.firewall.allowedUDPPorts = [ voiceChatPort ];
}
