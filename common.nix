{ config, pkgs, ... }:

{
  imports = [ ./users/david.nix ];

  system.stateVersion = "20.09";

  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  hardware.opengl = {
    enable = config.services.xserver.enable;
    driSupport32Bit = true;
  };
  hardware.pulseaudio = {
    enable = config.services.xserver.enable;
    support32Bit = true;
  };

  environment.systemPackages = with pkgs; [ neovim git ];
}
