{ config, lib, pkgs, ... }:

let
  cozy = pkgs.callPackage ./pkgs/cozy {};
in
{
  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/mmcblk0p1";
      fsType = "ext4";
    };
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../pkgs/linux-bpir2-4.14.nix {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.modinst_arg_list_too_long
    ];
  });

  boot.kernelPatches = [ {
    name = "ath5k-config";
    patch = null;
    extraConfig = ''
      WLAN_VENDOR_ATH y
      ATH5K_PCI y
    '';
  } ];

  boot.cleanTmpDir = true;

  hardware.enableRedistributableFirmware = true;
}
