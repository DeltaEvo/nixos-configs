let
	pkgs = import <nixpkgs> {};
in
{
  hello = pkgs.callPackage ./firmware.nix {};
}
