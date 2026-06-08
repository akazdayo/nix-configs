{
  description = "NixOS configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
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
      url = "github:akazdayo/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
      treefmt-nix,
      git-hooks,
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
            (import (./hosts/openstack + "/${hostName}/host-data.nix") { hostMeta = baseHostMeta; })
            ._module.args.hostData or { };
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
            (./hosts/openstack + "/${hostName}")
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${primaryUser} = import (./home/profiles/openstack + "/${hostName}");
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
        gateway = {
          sshUser = "deploy";
          remoteBuild = true;
          activationTimeout = 600;
        };
        minecraft = {
          sshUser = "deploy";
          remoteBuild = true;
          activationTimeout = 600;
        };
      };

      darwinHosts = {
        macbook = { };
      };

      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      mkPreCommitCheck =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          preCommitFmt = pkgs.writeShellApplication {
            name = "pre-commit-fmt";
            runtimeInputs = [ treefmtEval.config.build.wrapper ];
            text = ''
              exec ${pkgs.lib.getExe treefmtEval.config.build.wrapper} --no-cache -- "$@"
            '';
          };
        in
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nix-fmt = {
              enable = true;
              name = "nix fmt";
              entry = pkgs.lib.getExe preCommitFmt;
              files = "\\.(nix|lua|sh|md|json|toml|yaml|yml|rs)$";
            };
            check-added-large-files.enable = true;
            check-merge-conflicts.enable = true;
          };
        };

      mkDeployNode =
        hostName:
        {
          deployHostname ? hostName,
          sshUser ? defaultPrimaryUser,
          system ? "x86_64-linux",
          remoteBuild ? false,
          activationTimeout ? null,
          ...
        }:
        {
          hostname = deployHostname;
          sshOpts = [
            "-i"
            "~/.ssh/id_ed25519_sk_rk"
          ];
          profiles.system = {
            inherit sshUser;
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostName};
          };
        }
        // lib.optionalAttrs remoteBuild { inherit remoteBuild; }
        // lib.optionalAttrs (activationTimeout != null) { inherit activationTimeout; };
    in
    {
      nixosConfigurations =
        (lib.mapAttrs mkHost hosts)
        // (lib.mapAttrs mkServer servers)
        // (lib.mapAttrs mkOpenStackHost openstackHosts);

      darwinConfigurations = lib.mapAttrs mkDarwinHost darwinHosts;

      deploy.nodes = lib.mapAttrs mkDeployNode (hosts // servers // openstackHosts);

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          deploy-rs = deploy-rs.packages.${system}.default;
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          deploy-openstack-script = pkgs.writeShellScript "deploy-openstack" ''
            set -euo pipefail
            TARGET_HOST="''${1:-}"
            if [ -z "$TARGET_HOST" ]; then
              echo "Usage: nix run .#deploy-openstack -- <hostname>" >&2
              exit 1
            fi
            HOST=$(${pkgs.opentofu}/bin/tofu -chdir=infra/openstack/$TARGET_HOST output -raw ssh_host)
            exec ${deploy-rs.packages.${system}.default}/bin/deploy .#$TARGET_HOST --hostname "$HOST" "''${@:2}"
          '';
        in
        {
          deploy-openstack = {
            type = "app";
            program = "${deploy-openstack-script}";
            meta.description = "Deploy an OpenStack host using deploy-rs, resolving SSH host from OpenTofu output";
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          preCommit = mkPreCommitCheck system;
        in
        {
          default = pkgs.mkShell {
            inherit (preCommit) shellHook;
            packages = preCommit.enabledPackages ++ [
              deploy-rs.packages.${system}.default
              pkgs.nixfmt
              pkgs.opentofu
              pkgs.sops
              pkgs.age
              pkgs.age-plugin-yubikey
              pkgs.ssh-to-age
              pkgs.python3Packages.python-openstackclient
            ];
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
      );

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatting = treefmtEval.config.build.check self;
          pre-commit-check = mkPreCommitCheck system;
        }
      );
    };
}
