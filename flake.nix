{
  description = "NixOS configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    iets.url = "github:numtide/iets";
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cache-skills = {
      url = "github:yutakobayashidev/skills";
      flake = false;
    };
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kopuz = {
      url = "github:Kopuz-org/kopuz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    repro2 = {
      url = "github:bot-uichan/repro2/feat/tailscale-idp";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    wivrn-nix = {
      url = "github:akazdayo/wivrn-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    rebocap = {
      url = "github:akazdayo/rebocap-linux";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      nixvim,
      llm-agents,
      treefmt-nix,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      defaultPrimaryUser = "akazdayo";

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs supportedSystems;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkPkgsUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

      mkPkgsWithLlmAgents =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ llm-agents.overlays.shared-nixpkgs ];
        };

      nixosHosts = {
        milk.role = "desktop";
        milfy.role = "wsl";
      };

      darwinHosts.chiffon = {
        system = "aarch64-darwin";
        role = "desktop";
      };

      mkHostMeta =
        platform: hostName: spec:
        let
          primaryUser = spec.primaryUser or defaultPrimaryUser;
          system = spec.system or (if platform == "darwin" then "aarch64-darwin" else "x86_64-linux");
          flakeRoot =
            spec.flakeRoot or (
              if platform == "darwin" then "/Users/${primaryUser}/configs" else "/home/${primaryUser}/configs"
            );
        in
        {
          inherit
            hostName
            system
            platform
            primaryUser
            flakeRoot
            ;
          inherit (spec) role;
        };

      mkHomeManagerConfig =
        hostMeta:
        let
          inherit (hostMeta) system;
        in
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit self inputs hostMeta;
            pkgs-unstable = mkPkgsUnstable system;
            pkgs-with-llm-agents = mkPkgsWithLlmAgents system;
            nixvim-module = nixvim.homeModules.nixvim;
          };
        };

      mkNixosHost =
        hostName: spec:
        let
          hostMeta = mkHostMeta "nixos" hostName spec;
          inherit (hostMeta) system;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs hostMeta;
            pkgs-unstable = mkPkgsUnstable system;
          };
          modules = [
            { nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ]; }
            home-manager.nixosModules.home-manager
            (mkHomeManagerConfig hostMeta)
            (./hosts + "/${hostName}")
          ];
        };

      mkDarwinHost =
        hostName: spec:
        let
          hostMeta = mkHostMeta "darwin" hostName spec;
          inherit (hostMeta) system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit self inputs hostMeta;
            pkgs-unstable = mkPkgsUnstable system;
          };
          modules = [
            { nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ]; }
            home-manager.darwinModules.home-manager
            (mkHomeManagerConfig hostMeta)
            (./hosts + "/${hostName}")
          ];
        };

    in
    {
      nixosConfigurations = lib.mapAttrs mkNixosHost nixosHosts;
      darwinConfigurations = lib.mapAttrs mkDarwinHost darwinHosts;
      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt
              pkgs.sops
              pkgs.age
              pkgs.age-plugin-yubikey
              pkgs.ssh-to-age
            ];
          };
        }
      );

      formatter = forAllSystems (
        system: ((treefmt-nix.lib.evalModule (mkPkgs system) ./treefmt.nix).config.build.wrapper)
      );

      checks = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatting = treefmtEval.config.build.check self;
        }
      );
    };
}
