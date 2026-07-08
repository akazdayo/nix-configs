{
  config,
  lib,
  pkgs,
  hostMeta,
  ...
}:
let
  enableWakatime = hostMeta.hostName == "milk";
  configPath = "${config.home.homeDirectory}/.wakatime.cfg";
in
{
  home.activation.configureWakatime = lib.mkIf enableWakatime (
    lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
      secret_file=/run/secrets/wakatime-api-key
      cfg_file=${lib.escapeShellArg configPath}

      if [ -s "$secret_file" ]; then
        api_key="$(${pkgs.coreutils}/bin/tr -d '\n\r' < "$secret_file")"
        if [ "$api_key" = "REPLACE_ME" ]; then
          echo "WakaTime: replace sops key 'api-key' in secrets/milk/wakatime.yaml, then rerun nh os switch." >&2
        else
          ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$cfg_file"
          {
            printf '[settings]\n'
            printf 'api_key = %s\n' "$api_key"
          } > "$cfg_file"
        fi
      else
        echo "WakaTime: set sops key 'api-key' in secrets/milk/wakatime.yaml, then rerun nh os switch." >&2
      fi
    ''
  );
}
