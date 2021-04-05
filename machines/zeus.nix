{ pkgs, config, ... }: {

  imports = [ ../hardware/thinkpad_e570.nix ../common.nix ];

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
}
