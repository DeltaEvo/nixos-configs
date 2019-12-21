{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/boot/pi" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "cma=32M" ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      name = "broadcom-rpi3-extra";
      src = pkgs.fetchurl {
        url =
          "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
        sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
      };
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
      '';
    })
  ];
}
