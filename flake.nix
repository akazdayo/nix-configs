{
  description = "NixOS configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # QuickShell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    minecraft-nix = {
      url = "github:akazdayo/minecraft-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
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
      lanzaboote,
      deploy-rs,
      nix-flatpak,
      noctalia,
      llm-agents,
      minecraft-nix,
      nix-cachyos-kernel,
      sops-nix,
    }@inputs:
    let
      lib = nixpkgs.lib;
      defaultPrimaryUser = "akazdayo";

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
          overlays = [ llm-agents.overlays.default ];
        };

      mkHost =
        hostName:
        {
          system ? "x86_64-linux",
          primaryUser ? defaultPrimaryUser,
          flakeRoot ? null,
          ...
        }:
        let
          resolvedFlakeRoot = if flakeRoot == null then "/home/${primaryUser}/configs" else flakeRoot;
          baseHostMeta = {
            inherit hostName system primaryUser;
            flakeRoot = resolvedFlakeRoot;
          };
          hostData =
            (import (./hosts + "/${hostName}/host-data.nix") { hostMeta = baseHostMeta; })._module.args.hostData
              or { };
          hostMeta = baseHostMeta // {
            inherit hostData;
          };
          pkgs-unstable = mkPkgsUnstable system;
          pkgs-with-llm-agents = mkPkgsWithLlmAgents system;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              inputs
              pkgs-unstable
              hostMeta
              ;
          };
          modules = [
            ./packages
            (./hosts + "/${hostName}")
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${primaryUser} = import ./home/profiles/desktop.nix;
              home-manager.extraSpecialArgs = {
                inherit
                  self
                  pkgs-unstable
                  pkgs-with-llm-agents
                  inputs
                  hostMeta
                  ;
                nixvim-module = nixvim.homeModules.nixvim;
              };
            }
          ];
        };

      mkServer =
        hostName:
        {
          system ? "x86_64-linux",
          primaryUser ? defaultPrimaryUser,
          flakeRoot ? null,
          ...
        }:
        let
          resolvedFlakeRoot = if flakeRoot == null then "/home/${primaryUser}/configs" else flakeRoot;
          baseHostMeta = {
            inherit hostName system primaryUser;
            flakeRoot = resolvedFlakeRoot;
          };
          hostData =
            (import (./hosts + "/${hostName}/host-data.nix") { hostMeta = baseHostMeta; })._module.args.hostData
              or { };
          hostMeta = baseHostMeta // {
            inherit hostData;
          };
          pkgs-unstable = mkPkgsUnstable system;
          pkgs-with-llm-agents = mkPkgsWithLlmAgents system;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              inputs
              pkgs-unstable
              hostMeta
              ;
          };
          modules = [
            ./packages
            (./hosts + "/${hostName}")
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${primaryUser} = import ./home/profiles/server.nix;
              home-manager.extraSpecialArgs = {
                inherit
                  self
                  pkgs-unstable
                  pkgs-with-llm-agents
                  inputs
                  hostMeta
                  ;
                nixvim-module = nixvim.homeModules.nixvim;
              };
            }
          ];
        };

      mkOpenStackHost =
        hostName:
        {
          system ? "x86_64-linux",
          primaryUser ? defaultPrimaryUser,
          flakeRoot ? null,
          ...
        }:
        let
          resolvedFlakeRoot = if flakeRoot == null then "/home/${primaryUser}/configs" else flakeRoot;
          baseHostMeta = {
            inherit hostName system primaryUser;
            flakeRoot = resolvedFlakeRoot;
          };
          hostData =
            (import (./hosts + "/${hostName}/host-data.nix") { hostMeta = baseHostMeta; })._module.args.hostData
              or { };
          hostMeta = baseHostMeta // {
            inherit hostData;
          };
          pkgs-unstable = mkPkgsUnstable system;
          pkgs-with-llm-agents = mkPkgsWithLlmAgents system;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              inputs
              pkgs-unstable
              hostMeta
              ;
          };
          modules = [
            ./packages
            (./hosts + "/${hostName}")
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${primaryUser} = import ./home/profiles/openstack.nix;
              home-manager.extraSpecialArgs = {
                inherit
                  self
                  pkgs-unstable
                  pkgs-with-llm-agents
                  inputs
                  hostMeta
                  ;
                nixvim-module = nixvim.homeModules.nixvim;
              };
            }
          ];
        };

      mkDarwinHost =
        hostName:
        {
          system ? "aarch64-darwin",
          primaryUser ? defaultPrimaryUser,
          flakeRoot ? null,
        }:
        let
          resolvedFlakeRoot = if flakeRoot == null then "/Users/${primaryUser}/configs" else flakeRoot;
          baseHostMeta = {
            inherit hostName system primaryUser;
            flakeRoot = resolvedFlakeRoot;
          };
          hostData =
            (import (./hosts + "/${hostName}/host-data.nix") { hostMeta = baseHostMeta; })._module.args.hostData
              or { };
          hostMeta = baseHostMeta // {
            inherit hostData;
          };
          pkgs-unstable = mkPkgsUnstable system;
          pkgs-with-llm-agents = mkPkgsWithLlmAgents system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              inputs
              pkgs-unstable
              hostMeta
              ;
          };
          modules = [
            ./packages
            (./hosts + "/${hostName}")
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${primaryUser} = import ./home/profiles/darwin.nix;
              home-manager.extraSpecialArgs = {
                inherit
                  self
                  pkgs-unstable
                  pkgs-with-llm-agents
                  inputs
                  hostMeta
                  ;
                nixvim-module = nixvim.homeModules.nixvim;
              };
            }
          ];
        };

      hosts = {
        nixos = {
          deployHostname = "192.168.11.48";
        };
      };

      servers = {
        server = {
          deployHostname = "192.168.11.50";
        };
      };

      openstackHosts = {
        openstack = { };
      };

      darwinHosts = {
        macbook = { };
      };

      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      mkDeployNode =
        hostName:
        {
          deployHostname ? hostName,
          system ? "x86_64-linux",
          ...
        }:
        {
          hostname = deployHostname;
          sshOpts = [
            "-i"
            "~/.ssh/id_ed25519_sk_rk"
          ];
          profiles.system = {
            sshUser = defaultPrimaryUser;
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostName};
          };
        };
    in
    {
      nixosConfigurations = (lib.mapAttrs mkHost hosts) // (lib.mapAttrs mkServer servers) // (lib.mapAttrs mkOpenStackHost openstackHosts);

      darwinConfigurations = lib.mapAttrs mkDarwinHost darwinHosts;

      deploy.nodes = lib.mapAttrs mkDeployNode (hosts // servers);

      checks = lib.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              deploy-rs.packages.${system}.default
              pkgs.nixfmt-rfc-style
              pkgs.opentofu
              pkgs.sops
              pkgs.age
              pkgs.age-plugin-yubikey
              pkgs.ssh-to-age
            ];
          };
        }
      );
    };
}
