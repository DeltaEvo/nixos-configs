{ config, pkgs, ... }:

{
  imports = [
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>

    <nixpkgs/nixos/modules/installer/scan/detected.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>

    <nixpkgs/nixos/modules/profiles/all-hardware.nix>

    ../common.nix
  ];

  networking.hostName = "OMEGA"; # Define your hostname.

  # ISO naming.
  isoImage.isoName =
    "OMEGA-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  isoImage.volumeID = "OMEGA";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;

  # Include support for various filesystems.
  boot.supportedFilesystems =
    [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  services.nixosManual.showManual = true;
  services.xserver.enable = true;
}
