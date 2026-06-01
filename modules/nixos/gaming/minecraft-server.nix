{
  inputs,
  hostMeta,
  pkgs,
  config,
  ...
}:
let
  minecraftData = hostMeta.hostData.minecraft or { };
  inherit (config.services.minecraft-servers) runDir;
  fabricSock = "${runDir}/fabric-smp.sock";
in
{
  imports = [ inputs.minecraft-nix.nixosModules.minecraft-servers ];

  nixpkgs.overlays = [ inputs.minecraft-nix.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.fabric-smp = {
      enable = true;
      package = (pkgs.fabricServers.fabric-26_1_2.override { jre_headless = pkgs.jdk25; });
      jvmOpts = minecraftData.jvmOpts or "-Xms4G -Xmx8G";

      extraStartPost = ''
        sleep 30
        ${pkgs.tmux}/bin/tmux -S ${fabricSock} send-keys \
          "gamerule playersSleepingPercentage 0" Enter
      '';

      serverProperties = {
        server-port = minecraftData.serverPort or 25565;
        motd = "NixOS Fabric Minecraft Server";
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        white-list = true;
        online-mode = true;
        view-distance = 10;
        simulation-distance = 10;
      };

      whitelist = {
        aomona = "02992baf-9329-4c6a-b893-3e4b5ce37ca1";
        akaz_dango = "644d4fc6-1525-4426-9eb9-7c7877883e81";
        tokuzou0829 = "67ddca9d-42aa-4522-adc8-ab904eff34cd";
        shu_tti = "379c2f07-08d5-4b0e-9fe6-6fd044723d64";
        t4ko_uwu = "aedb2b9b-2fd3-415b-aa29-bac9a430a618";
        moons14 = "ede38872-25c5-414f-a04e-278b521d9f41";
        fa0311 = "7dfc7f95-df6f-435f-85f4-71513cc8fa87";
        yuta_kobayashi = "cfcc92a7-7b55-4b45-a13f-0eebf716e5f3";
        nakasyou0 = "9f2055d0-ff7f-4f27-adf2-c7793ebdff6a";
        crocus_966 = "b4c6cdd7-3425-432d-9db5-4b0687393de2";
        TmakMrst = "a0ee7eb9-1db2-4c19-ae97-ebe1606e1751";
        tukiminn = "49df5f84-ccd6-4639-a4f4-11b6df52c333";
        marukun_ = "5dd7cfe6-340f-4e3d-96e5-16d98d22c720";
      };

      operators = {
        moons14 = {
          uuid = "ede38872-25c5-414f-a04e-278b521d9f41";
          level = 1;
          bypassesPlayerLimit = false;
        };
        akaz_dango = {
          uuid = "644d4fc6-1525-4426-9eb9-7c7877883e81";
          level = 4;
          bypassesPlayerLimit = true;
        };
      };

      symlinks.mods = pkgs.linkFarmFromDrvs "mods" (
        builtins.attrValues {
          FabricApi = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar";
            sha512 = "238c793b720ed21d2d5b564eca88c714cf2188f7b0fb1fd30864660f80901e2b4dad273994b6f77de3c0aa365f930ed8aaccffac49b36c6456b153b52d5d21dc";
          };
          Lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/Nt50x0fz/lithium-fabric-0.24.3%2Bmc26.1.2.jar";
            sha512 = "b6f948576b062f83f1b13033c3f1121a3d4add8f8294415f8d283caeb91ca28acc1e19fb021a8807a034ff9875ef0dd9b6054734d552e072336aa060a106044f";
          };
          Carpet = pkgs.fetchurl {
            # https://github.com/gnembon/fabric-carpet/releases
            url = "https://github.com/gnembon/fabric-carpet/releases/download/v26.1/fabric-carpet-26.1+v260402.jar";
            sha256 = "59bd225d12423a7d7a635ca0c94fa786f97ccebb116922b16d76072da4ee67e7";
          };
          Servux = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/eu63Kj9A/servux-fabric-26.1.2-0.10.2.jar";
            sha512 = "78566cebcc5e181c68fc7f78c2f34213d634ae930f82cdfad19dd65ac4e6b24ae6d541a200b069e07e32e90b5c827d1cc1e80809da376bfbabfc8b302f9f256a";
          };
          Vivecraft = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/wGoQDPN5/versions/dAFnGtKk/vivecraft-26.1.2-1.3.8-fabric.jar";
            sha512 = "3228489a2ff1191d90a47c0a50d11aa19c6a818032c8657bd530e7c1fbd7cdfca5c2e3062c9da2de868407b83e94f16c57bc44d4537d9538b08f1d9f584037a9";
          };
          Polymer = pkgs.fetchurl {
            url = "https://github.com/Patbox/polymer/releases/download/0.16.5%2B26.1.2/polymer-bundled-0.16.5%2B26.1.2.jar";
            sha512 = "e9438712eecfd7560e9e4b67e8ff0907cddf024ecdea93fae7e8caab0a00a041a674040770bf7b25eef2220813baca1ee5b797f3b88de4b9f0f0449189d08642";
          };
          UniversalGraves = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/yn9u3ypm/versions/hI8eYRJ3/graves-3.11.1%2B26.1.2.jar";
            sha512 = "3caa63bb7d8f4ae3623310d13149de950e87f3b9083fce8a7dfe3083eea92dd2ab9721fabf27ebb6121deffc6f48af8b85f3543980381d588e6dcd667a7bf5e4";
          };
          SimpleVoiceChat = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/DpT86E4Q/voicechat-fabric-2.6.18%2B26.1.2.jar";
            sha512 = "9d9f38185c66fc57f03363a37d4559e58442bccb27414a4bd7c5a2b8bb046813afbcdf1bf6279b22f941f9cb4d2ed9d5e6dc4929714e73ae914a03557fb087af";
          };
          Syncmatica = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/bfneejKo/versions/hiDPXGGO/syncmatica-fabric-26.1.1-0.3.18.jar";
            sha512 = "c48f6e658ffc8cdce8647a149237f5aa7c35bb0cb5037024eb2bb6e6f3e2be863a733a010543ad206e295c5088d9bb400f2bb7a6d47f6b24a61921868491e9f2";
          };
        }
      );
    };
  };

  # Simple Voice Chat mod uses UDP 24454 by default.
  # openFirewall above only opens the Minecraft server TCP port;
  # the voice chat port must be opened explicitly.
  networking.firewall.allowedUDPPorts = [ 24454 ];
}
