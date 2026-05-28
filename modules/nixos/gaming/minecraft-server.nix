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
      package = pkgs.fabricServers.fabric-26.1.2;
      jvmOpts = minecraftData.jvmOpts or "-Xms4G -Xmx8G";

      serverProperties = {
        server-port = minecraftData.serverPort or 25565;
        motd = "NixOS Fabric Minecraft Server";
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        white-list = true;
        online-mode = true;
        view-distance = 10;
        simulation-distance = 10;
      };

      symlinks.mods = pkgs.linkFarmFromDrvs "mods" (
        builtins.attrValues {
          FabricApi = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar";
            sha512 = "238c793b720ed21d2d5b564eca88c714cf2188f7b0fb1fd30864660f80901e2b4dad273994b6f77de3c0aa365f930ed8aaccffac49b36c6456b153b52d5d21dc";
          };
        }
      );
    };
  };
}
