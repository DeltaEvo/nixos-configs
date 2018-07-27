{ config, pkgs, ... }:

{
	imports = [
		./home-manager.nix
		./users/david.nix
	];

	system.stateVersion = "18.09";

	time.timeZone = "Europe/Paris";

	nixpkgs.config.allowUnfree = true;

	networking.networkmanager.enable = true;

	environment.systemPackages = with pkgs; [
		neovim
		git
	];
}