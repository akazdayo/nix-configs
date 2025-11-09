{...}: {
  users.users.akazdayo = {
    isNormalUser = true;
    description = "akazdayo";
    extraGroups = ["networkmanager" "wheel"];
  };
}
