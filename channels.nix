let
  fetchChannel = { rev, sha256 }: import (fetchTarball {
    inherit sha256;
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
  }) { config.allowUnfree = true; };
in
{
	stable = fetchChannel {
		rev = "69514d78a6b9e7912387fd01934f23f71938dcbb";
		sha256 = "050h9pa57kd57l73njxpjb331snybddl29x2vpy5ycygvqiw8kcp";
	};

	unstable = fetchChannel {
		rev = "7df10f388dabe9af3320fe91dd715fc84f4c7e8a";
		sha256 = "14n9nwdmd1jvvic1rnyw4023fm97b0xn4nq801l29vpnfzyab04w";
	};
}