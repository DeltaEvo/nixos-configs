{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  inputs.david-config = {
    url = "github:DeltaEvo/.config";
    flake = false;
  };

  outputs =
    { self, nixpkgs, nixpkgs_unstable, home-manager, deploy-rs, david-config }:
    let
      unstable-module = { config, ... }: {
        nixpkgs.overlays = [
          (final: prev: {
            unstable = import nixpkgs_unstable {
              config = config.nixpkgs.config;
              system = config.nixpkgs.localSystem.system;
            };
          })
        ];
      };
    in {
      nixosConfigurations.Zeus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit david-config; };
        modules = [
          (_args: {
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
          })
          (import ./machines/zeus.nix)
          unstable-module
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Hades = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit david-config; };
        modules = [
          (_args: {
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
          })
          (import ./machines/hades.nix)
          unstable-module
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Oracle = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit david-config; };
        modules = [
          (_args: {
            system.configurationRevision =
              nixpkgs.lib.mkIf (self ? rev) self.rev;
          })
          (import ./machines/oracle.nix)
          unstable-module
          home-manager.nixosModules.home-manager
        ];
      };

      deploy.nodes.Oracle = {
        hostname = "oracle.delta.sh";
        user = "root";
        sshUser = "root";
        autoRollback = false;
        profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.Oracle;
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
