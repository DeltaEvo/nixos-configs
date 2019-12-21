# $ nix-build omega.nix

(import <nixpkgs/nixos/lib/eval-config.nix> {
  system = "x86_64-linux";
  modules = [ ../machines/hera.nix ];
}).config.system.build.isoImage
