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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minecraft-nix = {
      url = "github:akazdayo/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    wivrn-nix.url = "github:akazdayo/wivrn-nix";
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
      deploy-rs,
      llm-agents,
      treefmt-nix,
      git-hooks,
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
        milk = {
          role = "desktop";
          deploy.hostname = "192.168.11.48";
        };
        hinata = {
          role = "server";
          deploy = {
            hostname = "192.168.11.50";
            sshUser = "deploy";
            remoteBuild = true;
            activationTimeout = 600;
          };
        };
        gateway = {
          role = "openstack";
          deploy = {
            sshUser = "deploy";
            remoteBuild = true;
            activationTimeout = 600;
          };
        };
        minecraft = {
          role = "openstack";
          deploy = {
            sshUser = "deploy";
            remoteBuild = true;
            activationTimeout = 600;
          };
        };
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
            home-manager.darwinModules.home-manager
            (mkHomeManagerConfig hostMeta)
            (./hosts + "/${hostName}")
          ];
        };

      mkPreCommitCheck =
        system:
        let
          pkgs = mkPkgs system;
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

      deployHosts = lib.filterAttrs (_: spec: spec ? deploy) nixosHosts;
      mkDeployNode =
        hostName: spec:
        let
          deploy = spec.deploy;
          system = spec.system or "x86_64-linux";
        in
        {
          hostname = deploy.hostname or hostName;
          sshOpts = [
            "-i"
            "~/.ssh/id_ed25519_sk_rk"
            "-o"
            "ControlMaster=auto"
            "-o"
            "ControlPersist=10m"
            "-o"
            "ControlPath=~/.ssh/deploy-rs-%C"
          ];
          profiles.system = {
            sshUser = deploy.sshUser or defaultPrimaryUser;
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostName};
          };
        }
        // lib.optionalAttrs (deploy.remoteBuild or false) { remoteBuild = true; }
        // lib.optionalAttrs (deploy ? activationTimeout) {
          inherit (deploy) activationTimeout;
        };
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixosHost nixosHosts;
      darwinConfigurations = lib.mapAttrs mkDarwinHost darwinHosts;
      deploy.nodes = lib.mapAttrs mkDeployNode deployHosts;

      packages = forAllSystems (system: {
        deploy-rs = deploy-rs.packages.${system}.default;
      });

      apps = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
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
          pkgs = mkPkgs system;
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
          pre-commit-check = mkPreCommitCheck system;
        }
      );
    };
}
