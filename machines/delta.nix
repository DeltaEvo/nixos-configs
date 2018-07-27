{ config, pkgs, ... }:

{
	imports = [
		../hardware/thinkpad_e570.nix
		../common.nix
	];

	networking.hostName = "DELTA"; # Define your hostname.


	# Development tools
	virtualisation.docker.enable = true;
	services.mongodb.enable = true;


}