{ config, lib, pkgs, ... }:

let
	rev = "dda65c0877b0b6c98d0f628374f2651d92597086";
in
{
	imports = [
		"${
			fetchTarball {
				url = "https://github.com/rycee/home-manager/archive/${rev}.tar.gz";
				sha256 = "1d4ha7c1kdns2p8aq067ygham9j9jds3vqhw6gpp4sggjlg3vid8";
			}
		}/nixos"
	];
}