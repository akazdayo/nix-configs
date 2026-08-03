{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.local.litellm;
  chatgptTokenDir = "${config.services.litellm.stateDir}/chatgpt";
  seedChatgptAuth = pkgs.writeShellScript "litellm-seed-chatgpt-auth" ''
    set -eu

    ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg chatgptTokenDir}
    if [ ! -s ${lib.escapeShellArg "${chatgptTokenDir}/auth.json"} ]; then
      ${pkgs.coreutils}/bin/install \
        -m 0600 \
        "$CREDENTIALS_DIRECTORY/chatgpt-auth.json" \
        ${lib.escapeShellArg "${chatgptTokenDir}/auth.json"}
    fi
  '';
in
{
  options.local.litellm = {
    host = lib.mkOption { type = lib.types.str; };
    port = lib.mkOption { type = lib.types.port; };
    environmentSopsFile = lib.mkOption { type = lib.types.path; };
    chatgptAuthSopsFile = lib.mkOption { type = lib.types.path; };
  };

  config = {
    sops.secrets = {
      litellm-env = {
        sopsFile = cfg.environmentSopsFile;
        owner = "root";
        mode = "0400";
      };
      litellm-chatgpt-auth = {
        sopsFile = cfg.chatgptAuthSopsFile;
        owner = "root";
        mode = "0400";
      };
    };

    services.litellm = {
      enable = true;
      package = pkgs-unstable.litellm;
      inherit (cfg) host port;
      openFirewall = true;
      environmentFile = config.sops.secrets.litellm-env.path;
      environment.CHATGPT_TOKEN_DIR = chatgptTokenDir;

      settings = {
        model_list = [
          {
            model_name = "chatgpt/*";
            litellm_params.model = "chatgpt/*";
          }
        ];

        general_settings = {
          master_key = "os.environ/LITELLM_MASTER_KEY";
          disable_spend_logs = true;
        };
      };
    };

    systemd.services.litellm.serviceConfig = {
      LoadCredential = [
        "chatgpt-auth.json:${config.sops.secrets.litellm-chatgpt-auth.path}"
      ];
      ExecStartPre = lib.mkAfter [ seedChatgptAuth ];
    };
  };
}
