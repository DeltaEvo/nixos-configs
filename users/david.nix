{ config, lib, pkgs, ... }:

let 
	polybar = pkgs.polybar.override { i3GapsSupport = true; githubSupport = true; mpdSupport = true; };
	minecraft = pkgs.minecraft.override { useAlsa = true; };
	python3 = pkgs.python36.withPackages (ps : [ps.numpy]);
	winetricks = pkgs.winetricks.override { wine = pkgs.wineStaging; };
in
{
	users.extraUsers.david = {
	    isNormalUser = true;
	    home = "/home/david";
	    extraGroups = [ "wheel" "networkmanager" "docker" ];
	    shell = pkgs.fish;
	};

	programs.fish.enable = true;

	home-manager.users.data = {
		home.packages = with pkgs; ([
			manpages
			htop
			ntfs3g
			nodejs-9_x
			tmux
			acpi
			powertop
			git
			sshpass
			psmisc
			pciutils
			tor
			torsocks
			fortune
			ponysay
			rustup
			wget
			valgrind
			cmatrix
			unrar
			unzip
			neovim
			universal-ctags
			python3
			gdb
			gnumake
			cmake
  		] ++ pkgs.lib.optionals config.services.xserver.enable [
			feh
			glxinfo
			albert
			units
			polybar
			vscode
#			steam
			discord
#			tdesktop
			minecraft
			yubikey-personalization-gui
			yubioath-desktop
#			spotify
			hyper
			conky
			i3lock
			firefox-devedition-bin
			winetricks
			electrum
  		]);
		gtk = pkgs.lib.mkIf config.services.xserver.enable {
			enable = true;
			theme = {
				package = pkgs.arc-theme;
				name = "Arc-Dark";
    		};
    		iconTheme = {
				package = pkgs.papirus-icon-theme;
				name = "Papirus-Dark";
    		};
  		};
	};
}