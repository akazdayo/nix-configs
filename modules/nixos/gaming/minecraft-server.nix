{ pkgs, ... }:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.papermcServers.papermc-1_21_10;
    openFirewall = true;

    declarative = true;
    serverProperties = {
      server-port = 25565;
      motd = "NixOS Paper Minecraft Server";
    };
  };
}
