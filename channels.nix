let
  fetchChannel = { rev, sha256 }: import (fetchTarball {
    inherit sha256;
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
  }) { config.allowUnfree = true; };
in
{
	stable = fetchChannel {
		rev = "98e3b90b6c8f400ae5438ef868eb992a64b75ce5";
		sha256 = "0p8ixjww40bxbsa2vzhnqah8a5wqrqjrm3k6wxywm0pfcx7jcwx7";
	};

	unstable = fetchChannel {
		rev = "4649b6ef4b5e7a98d84a36fc7f0a89c65c4c7ad1";
		sha256 = "1wwqr40jcf7pqr5x9rwz1m42z07sbzawq5d1nyf7h5ccwk25q9mj";
	};
}
