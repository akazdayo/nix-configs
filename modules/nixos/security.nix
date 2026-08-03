{ ... }:
{
  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {
        settings = {
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 5;
          findtime = 600;
          bantime = 3600;
        };
      };
    };
  };
}
