{ config }:
{
  discordIntegrationConfig = {
    discord = {
      enabled = true;
      token = config.sops.placeholder.discord-token;
      channelId = config.sops.placeholder.discord-channel-id;
      status = "Minecraft chat";
    };
    minecraft = {
      broadcastDiscordMessages = true;
      broadcastMinecraftChatToOtherServers = true;
      syncedServers = [
        "smp"
        "creative"
      ];
    };
    embeds = {
      joinLeave = true;
      serverSwitch = true;
      death = true;
      joinColor = 4437377;
      leaveColor = 15746887;
      switchColor = 16426522;
      deathColor = 10038562;
    };
  };
}
