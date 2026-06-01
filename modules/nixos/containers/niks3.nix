{
  config,
  hostMeta,
  inputs,
  ...
}:
let
  containerData = hostMeta.hostData.containers;
  niks3Data = containerData.niks3;
  credentialDir = "/run/credentials/niks3.service";
in
{
  systemd.tmpfiles.rules = [
    "d ${niks3Data.hostDataRoot} 0755 root root -"
    "d ${niks3Data.hostDataRoot}/postgres 0755 root root -"
  ];

  systemd.services."container@niks3" = {
    after = [ "container@rustfs.service" ];
    wants = [ "container@rustfs.service" ];
  };

  containers.niks3 = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ containerData.hostInterface ];
    bindMounts = {
      "/var/lib/postgresql" = {
        hostPath = "${niks3Data.hostDataRoot}/postgres";
        isReadOnly = false;
      };
      "/run/secrets/niks3-api-token" = {
        hostPath = niks3Data.secretHostPaths.apiToken;
        isReadOnly = true;
      };
      "/run/secrets/niks3-signing-key" = {
        hostPath = niks3Data.secretHostPaths.signingKey;
        isReadOnly = true;
      };
      "/run/secrets/niks3-s3-access-key" = {
        hostPath = niks3Data.secretHostPaths.s3AccessKey;
        isReadOnly = true;
      };
      "/run/secrets/niks3-s3-secret-key" = {
        hostPath = niks3Data.secretHostPaths.s3SecretKey;
        isReadOnly = true;
      };
    };

    config =
      { ... }:
      {
        imports = [
          inputs.niks3.nixosModules.niks3
        ];

        networking.hostName = niks3Data.hostName;
        networking.interfaces.${containerData.containerInterface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = niks3Data.address;
              prefixLength = niks3Data.prefixLength;
            }
          ];
        };
        networking.defaultGateway = containerData.defaultGateway;
        networking.nameservers = containerData.nameservers;
        networking.firewall.allowedTCPPorts = [ 5751 ];

        services.niks3 = {
          enable = true;
          httpAddr = "0.0.0.0:5751";
          apiTokenFile = "${credentialDir}/api-token";
          signKeyFiles = [ "${credentialDir}/signing-key" ];
          cacheUrl = "https://${niks3Data.cacheDomain}";
          readProxy.enable = true;
          database = {
            createLocally = true;
          };

          s3 = {
            endpoint = niks3Data.s3.endpoint;
            bucket = niks3Data.s3.bucket;
            region = niks3Data.s3.region;
            useSSL = true;
            accessKeyFile = "${credentialDir}/s3-access-key";
            secretKeyFile = "${credentialDir}/s3-secret-key";
          };

          oidc.providers.github = {
            issuer = "https://token.actions.githubusercontent.com";
            audience = "https://${niks3Data.cacheDomain}";
            boundClaims = {
              repository = [ "akazdayo/nix-configs" ];
              ref = [ "refs/heads/main" ];
            };
          };

          gc = {
            enable = true;
            olderThan = "4320h";
            failedUploadsOlderThan = "6h";
            schedule = "daily";
            randomizedDelaySec = 1800;
          };
        };

        systemd.services.niks3.serviceConfig.LoadCredential = [
          "api-token:/run/secrets/niks3-api-token"
          "signing-key:/run/secrets/niks3-signing-key"
          "s3-access-key:/run/secrets/niks3-s3-access-key"
          "s3-secret-key:/run/secrets/niks3-s3-secret-key"
        ];

        system.stateVersion = "25.11";
      };
  };

  services.niks3-auto-upload = {
    enable = true;
    serverUrl = "http://${niks3Data.address}:5751";
    authTokenFile = config.sops.secrets.niks3-api-token.path;
  };
}
