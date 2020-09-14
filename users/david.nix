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
    extraGroups = [ "wheel" "networkmanager" "docker" "vboxusers" ];
    shell = pkgs.unstable.fish;
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
    home.file = lib.listToAttrs (map (name:
      (lib.nameValuePair ".config/${name}" ({
        source = "${david-config}/${name}";
      }))) (builtins.attrNames (builtins.readDir david-config)));

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
        winetricks
        #			electrum
      ]);

    xsession = pkgs.lib.mkIf config.services.xserver.enable {
      enable = true;
      windowManager.awesome = { enable = true; };
    };
    services.picom.enable = config.services.xserver.enable;

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
