{ config, lib, pkgs, ... }:

let
	sysPkgs = pkgs;
	channels = import ../channels.nix;
	pkgs = channels.unstable;
	polybar = pkgs.polybar.override { i3GapsSupport = true; githubSupport = true; mpdSupport = true; };
	winetricks = pkgs.winetricks.override { wine = pkgs.wineStaging; };
	confDir = ./david.config;
in
{
	users.extraUsers.david = {
	    isNormalUser = true;
	    home = "/home/david";
	    extraGroups = [ "wheel" "networkmanager" "docker" ];
	    shell = sysPkgs.fish;
	};

	programs.fish.enable = true;

	services.udev.packages = with sysPkgs; [
		yubikey-personalization
	];

	home-manager.users.david = {
		home.file = lib.listToAttrs (
			map (
				name: (lib.nameValuePair ".config/${name}" ({ source = "${confDir}/${name}"; }) )
			) (builtins.attrNames (builtins.readDir confDir))
		);

		home.packages = with pkgs; ([
			manpages
			htop
			ntfs3g
			nodejs-10_x
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
			gnupg
  		] ++ pkgs.lib.optionals config.services.xserver.enable [
			glxinfo
			vscode
#			steam
			discord
#			tdesktop
			minecraft
			yubikey-personalization-gui
			yubioath-desktop
#			spotify
			kitty
			firefox-devedition-bin
			winetricks
#			electrum
  		]);

		xsession = pkgs.lib.mkIf config.services.xserver.enable {
			enable = true;
			windowManager.awesome = {
				enable = true;
			};
		};

		gtk = {
			enable = config.services.xserver.enable;
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