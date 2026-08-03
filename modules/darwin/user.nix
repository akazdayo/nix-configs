{ hostMeta, ... }:
{
  system.primaryUser = hostMeta.primaryUser;
  users.users.${hostMeta.primaryUser}.home = "/Users/${hostMeta.primaryUser}";
}
