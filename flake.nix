{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs_unstable = { url = "github:NixOS/nixpkgs/nixos-unstable"; flake = false; };
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.david-config = { url = "github:DeltaEvo/.config"; flake = false; };

  outputs = { self, nixpkgs, nixpkgs_unstable, home-manager, david-config }: {
    nixosConfigurations.Zeus = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit david-config; };
      modules = [
        ({ pkgs, config, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs_unstable { config = { allowUnfree = true; }; inherit system; };
            })
          ];

          imports = [ ./hardware/thinkpad_e570.nix ./common.nix ];

          networking.hostName = "Zeus";

          # Development tools
          virtualisation.docker.enable = true;
          services.mongodb.enable = true;
          services.mysql.enable = true;
          services.mysql.package = pkgs.mariadb;

          services.xserver.enable = true;
          services.xserver.displayManager.defaultSession = "xsession";
          services.xserver.displayManager.session = [
            {
              manage = "desktop";
              name = "xsession";
              start = ''exec $HOME/.xsession'';
            }
          ];

          # Disable bluetooth it suck batery
          hardware.bluetooth.enable = false;

          home-manager.useGlobalPkgs = true;

          boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

          virtualisation.virtualbox.host.enable = true;

          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
        })
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.Hades = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit david-config; };
      modules = [
        ({ pkgs, config, ... }: {
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs_unstable { config = { allowUnfree = true; }; inherit system; };
            })
          ];

          imports = [ ./hardware/matebook_x.nix ./common.nix ];

          networking.hostName = "Hades";

          # Development tools
          virtualisation.docker.enable = true;

          services.xserver.enable = true;
          services.xserver.desktopManager.xterm.enable = true;

          # Disable bluetooth it suck batery
          hardware.bluetooth.enable = false;

          home-manager.useGlobalPkgs = true;

          virtualisation.virtualbox.host.enable = true;

	  security.sudo.wheelNeedsPassword = false;

          nix.package = pkgs.nixUnstable;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
        })
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
