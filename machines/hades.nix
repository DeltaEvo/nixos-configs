{ pkgs, config, ... }: {

  imports = [ ../hardware/matebook_x.nix ../common.nix ];

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
}
