{ config, lib, pkgs, david-config, ... }:

let
  polybar = pkgs.unstable.polybar.override {
    i3GapsSupport = true;
    githubSupport = true;
    mpdSupport = true;
  };
  winetricks = pkgs.unstable.winetricks.override { wine = pkgs.unstable.wineStaging; };
in {
  users.extraUsers.david = {
    isNormalUser = true;
    home = "/home/david";
    extraGroups = [ "wheel" "networkmanager" "docker" "vboxusers" "dialout" ];
    shell = pkgs.unstable.fish;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDowHs9CSn76pFw8l5p0uI27hiZB/ZuV1aEeVrDoqjRvNFAs9jy6KzHk8E85+VckfaDv+u2ZQA4NtJHW+PIntrbeCz06soTspMqFUbZ5ombR8ywwlJhKsS0aDwtNpPHhvzv3A1+Vkbp1pI4p40IT5li48WBDQ4f5UTW81WK96XZpw2dW7RDiWNDoH848nBbhE+NY7TcmlI1czQPbuAsH0Sl/nYxEoTUU/I7UwBIcZpvVl/qs3uE4qSaaWR9O+LXKnvpr/F5RMTcIEg5q7qK442rOPn2o+9Qwwm7sttTLYIFyrZa+wZYMjzB/FWGHIqtWb4lZZEJSEvR+ji6u1FpCiBZ deltaduartedavid@gmail.com"
    ];
  };

  programs.fish.enable = true;

  programs.adb.enable = true;

  services.udev.packages = with pkgs; [ yubikey-personalization ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # For Eiffel
  boot.blacklistedKernelModules = [ "btusb" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", GROUP="wheel"
  '';

  services.pcscd.enable = true;

  home-manager.users.david = {
    home.file = builtins.removeAttrs (lib.listToAttrs (map (name:
      (lib.nameValuePair ".config/${name}" ({
        source = "${david-config}/${name}";
     }))) (builtins.attrNames (builtins.readDir david-config)))) [".config/fish"];

    home.packages = with pkgs.unstable;
      ([
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
        gsettings-desktop-schemas
        winetricks
        #			electrum
      ]);

    home.keyboard = null; # Let system chose keyboard

    xsession = pkgs.lib.mkIf config.services.xserver.enable {
      enable = true;
      windowManager.awesome = { enable = true; };
    };
    services.picom.enable = config.services.xserver.enable;

    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "theme-bobthefish";
          src = let
	    bobthefish = pkgs.fetchFromGitHub {
	      owner = "oh-my-fish";
              repo = "theme-bobthefish";
              rev = "12b829e0bfa0b57a155058cdb59e203f9c1f5db4";
              sha256 = "00by33xa9rpxn1rxa10pvk0n7c8ylmlib550ygqkcxrzh05m72bw";
            };
	  in
	  pkgs.runCommand "theme-bobthefish" {} ''
	    mkdir -p $out/functions
	    cp -r ${bobthefish}/functions/*.fish $out/functions
	    cp ${bobthefish}/*.fish $out/functions
	  '';
        }
      ];
    };

    gtk = {
      enable = config.services.xserver.enable;
      theme = {
        package = pkgs.unstable.arc-theme;
        name = "Arc-Dark";
      };
      iconTheme = {
        package = pkgs.unstable.papirus-icon-theme;
        name = "Papirus-Dark";
      };
    };

    services.redshift = {
      enable = config.services.xserver.enable;
      # Paris
      latitude = "48.86";
      longitude = "2.33";
    };
  };
}
