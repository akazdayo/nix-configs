{
  inputs,
  hostMeta,
  pkgs,
  ...
}:
let
  minecraftData = hostMeta.hostData.minecraft or { };
in
{
  imports = [ inputs.minecraft-nix.nixosModules.minecraft-servers ];

  nixpkgs.overlays = [ inputs.minecraft-nix.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric-smp = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_5;
      jvmOpts = minecraftData.jvmOpts or "-Xms4G -Xmx8G";

      serverProperties = {
        server-port = minecraftData.serverPort or 25565;
        motd = "NixOS Fabric Minecraft Server";
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        white-list = false;
        online-mode = true;
        view-distance = 10;
        simulation-distance = 10;
      };

      symlinks.mods = pkgs.linkFarmFromDrvs "mods" (
        builtins.attrValues {
          FabricApi = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/kKEGlsne/fabric-api-0.128.2%2B1.21.5.jar";
            sha512 = "0e42b72d1a63a45c1b64cdabafd15f4d236bbda5521964d687afa1f833d4022f96c7ffab5dd4471aba0190be588f092d156bf14a50b794895fb3286ec899bcf7";
          };
        }
      );
    };
  };
}
