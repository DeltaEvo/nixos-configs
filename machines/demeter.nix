{ config, pkgs, ... }:

{
  imports = [ ../hardware/raspberrypi3.nix ../common.nix ];

  networking.hostName = "Demeter"; # Define your hostname.

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
}
