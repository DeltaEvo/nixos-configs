# This file was generated by https://github.com/kamilchm/go2nix v1.2.1
{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "cozy-stack-unstable-${version}";
  version = "2019-02-08";
  rev = "7e5a32dd1943cd45c8f9bb39be6d2fc23c066aa5";

  goPackagePath = "github.com/cozy/cozy-stack";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/cozy/cozy-stack.git";
    sha256 = "0v8l7v6l8im2qp1kd45pjz8g9si635qmyycim49gdgks50a22qdz";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
