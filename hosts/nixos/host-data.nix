{ hostMeta, ... }:
let
  hostData = {
    networking = {
      nameservers = [ "192.168.11.62" ];
    };

    users.${hostMeta.primaryUser}.authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIuYLePldOwgtFXwo0sw48rBVzX2zHjzGshFq4V9xwMLAAAABHNzaDo= somanoda@25N1103630nodasoma.local"
    ];

    boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

    swap.device = "/var/lib/swapfile";

    fileSystems = {
      kioxia = {
        mountPoint = "/mnt/kioxia";
        device = "/dev/disk/by-uuid/7d2f187f-18cb-4c3b-8f5f-cccb8a337afc";
      };
      windows = {
        mountPoint = "/mnt/windows";
        device = "/dev/disk/by-uuid/9660FCA060FC886F";
      };
      vaio = {
        mountPoint = "/mnt/vaio";
        device = "/dev/disk/by-uuid/7AB6CF81B6CF3C7F";
        uuid = "7AB6CF81B6CF3C7F";
      };
    };

    immichBackups = {
      server = "http://192.168.11.61:2283";
      linuxVRChatFolder = "/home/akazdayo/.local/share/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat";
      windowsVRChatFolder = "/mnt/windows/Users/keenb/OneDrive/画像/VRChat";
    };

    ssh.matchBlocks."192.168.11.50" = {
      user = "akazdayo";
      identityFile = "~/.ssh/id_ed25519_sk_rk";
      identityAgent = "none";
    };
  };
in
{
  _module.args.hostData = hostData;
}
