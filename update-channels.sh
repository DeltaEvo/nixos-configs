#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash nix curl jq
#
# Updates the nixpkgs.json to the latest channel release
set -euo pipefail

getRev() {
  curl -sfL https://api.github.com/repos/NixOS/nixpkgs-channels/git/refs/heads/$1 | jq -r .object.sha
}

computeSha256() {
  nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$1.tar.gz

}

stable=$(getRev nixos-unstable)
echo Stable rev: $stable
unstable=$(getRev nixos-19.03)
echo Unstable rev: $unstable
stableHash=$(computeSha256 $stable)
unstableHash=$(computeSha256 $unstable)

cat <<EOF | tee channels.nix
let
  fetchChannel = { rev, sha256 }: import (fetchTarball {
    inherit sha256;
    url = "https://github.com/NixOS/nixpkgs-channels/archive/\${rev}.tar.gz";
  }) { config.allowUnfree = true; };
in
{
	stable = fetchChannel {
		rev = "$stable";
		sha256 = "$stableHash";
	};

	unstable = fetchChannel {
		rev = "$unstable";
		sha256 = "$unstableHash";
	};
}
EOF
