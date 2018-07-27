{ config, lib, pkgs, ... }:

let
	rev = "dda65c0877b0b6c98d0f628374f2651d92597086";
in
{
	imports = [
		 "${builtins.fetchTarball "https://github.com/rycee/home-manager/archive/${rev}.tar.gz"}/nixos"
	];
}