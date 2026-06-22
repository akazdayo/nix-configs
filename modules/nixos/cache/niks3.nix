{
  config,
  hostMeta,
  inputs,
  pkgs,
  ...
}:
let
  cacheData = hostMeta.hostData.cache;
in
{
  imports = [ inputs.niks3.nixosModules.niks3 ];

  sops.secrets = {
    niks3-api-token = {
      sopsFile = ../../../secrets/hinata/cache.yaml;
      owner = "niks3";
      mode = "0400";
    };
    niks3-signing-key = {
      sopsFile = ../../../secrets/hinata/cache.yaml;
      owner = "niks3";
      mode = "0400";
    };
    rustfs-access-key = {
      sopsFile = ../../../secrets/hinata/cache.yaml;
      owner = "root";
      group = "s3-cache";
      mode = "0440";
    };
    rustfs-secret-key = {
      sopsFile = ../../../secrets/hinata/cache.yaml;
      owner = "root";
      group = "s3-cache";
      mode = "0440";
    };
  };

  services.niks3 = {
    enable = true;
    package = inputs.niks3.packages.${pkgs.system}.niks3;
    serverPackage = inputs.niks3.packages.${pkgs.system}.niks3-server;

    httpAddr = cacheData.niks3.httpAddr;
    cacheUrl = "https://${cacheData.domain}";
    readProxy.enable = true;

    apiTokenFile = config.sops.secrets.niks3-api-token.path;
    signKeyFiles = [ config.sops.secrets.niks3-signing-key.path ];

    database.createLocally = true;

    s3 = {
      endpoint = cacheData.rustfs.endpoint;
      bucket = cacheData.bucket;
      region = "us-east-1";
      useSSL = false;
      accessKeyFile = config.sops.secrets.rustfs-access-key.path;
      secretKeyFile = config.sops.secrets.rustfs-secret-key.path;
    };
  };

  systemd.services.niks3 = {
    after = [
      "postgresql-setup.service"
      "rustfs-setup.service"
    ];
    requires = [
      "postgresql-setup.service"
      "rustfs-setup.service"
    ];
  };
}
