{
  hostMeta,
  ...
}:
let
  containerData = hostMeta.hostData.containers;
  livesyncData = containerData.obsidianLivesync;
in
{
  systemd.tmpfiles.rules = [
    "d ${livesyncData.hostDataRoot} 0755 root root -"
    "d ${livesyncData.hostDataRoot}/data 0750 5984 5984 -"
  ];

  containers.obsidian-livesync = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ containerData.hostInterface ];

    bindMounts = {
      "/var/lib/couchdb" = {
        hostPath = "${livesyncData.hostDataRoot}/data";
        isReadOnly = false;
      };
      "/run/secrets/couchdb-admin-yaml" = {
        hostPath = "/run/secrets/couchdb-admin-yaml";
        isReadOnly = true;
      };
    };

    config =
      { ... }:
      {
        networking.hostName = livesyncData.hostName;

        networking.interfaces.${containerData.containerInterface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = livesyncData.address;
              prefixLength = livesyncData.prefixLength;
            }
          ];
        };
        networking.defaultGateway = containerData.defaultGateway;
        networking.nameservers = containerData.nameservers;
        networking.firewall.allowedTCPPorts = [ 5984 ];

        # sops-nix extracts the value of the 'couchdb-admin-yaml' key,
        # so /run/secrets/couchdb-admin-yaml contains just the password string.
        # Generate [admins] INI section at boot.
        systemd.services.couchdb-admin-ini = {
          description = "Generate CouchDB admin INI from sops secret";
          wantedBy = [ "multi-user.target" ];
          before = [ "couchdb.service" ];
          requiredBy = [ "couchdb.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            umask 077
            PASSWORD=$(cat /run/secrets/couchdb-admin-yaml)
            cat > /run/couchdb/admin.ini << EOF
            [admins]
            admin = $PASSWORD
            EOF
          '';
        };

        services.couchdb = {
          enable = true;
          bindAddress = "0.0.0.0";
          port = 5984;
          adminUser = livesyncData.adminUser;
          extraConfigFiles = [
            "/run/couchdb/admin.ini"
          ];
          extraConfig = {
            couchdb = {
              single_node = true;
              max_document_size = "50000000";
            };
            chttpd = {
              require_valid_user = true;
              max_http_request_size = "4294967296";
              enable_cors = true;
            };
            chttpd_auth = {
              require_valid_user = true;
              authentication_redirect = "/_utils/session.html";
            };
            httpd = {
              "WWW-Authenticate" = ''Basic realm="couchdb"'';
              enable_cors = true;
            };
            cors = {
              origins = "app://obsidian.md,capacitor://localhost,http://localhost";
              credentials = true;
              headers = "accept, authorization, content-type, origin, referer";
              methods = "GET, PUT, POST, HEAD, DELETE";
              max_age = 3600;
            };
          };
        };

        system.stateVersion = "25.11";
      };
  };
}
