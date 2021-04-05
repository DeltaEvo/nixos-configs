{ stdenv, buildPackages, fetchFromGitHub, perl, buildLinux, ... } @ args:

buildLinux (args // rec {
  version = "4.14.101-bpi-r2";

  # modDirVersion needs to be x.y.z.
  modDirVersion = version;

  # branchVersion needs to be x.y.
  extraMeta.branch = "4.14";

  src = fetchFromGitHub {
    owner = "frank-w";
    repo = "BPI-R2-4.14";
    rev = "5dbf7374f4adf77facf28ddc26c08b2a50351d3b";
    sha256 = "1qlsxa6r2lcw0dv26fygcdfbl1yshfcf0pjs3z5zwxarva7skj5k";
  };

  defconfig = "mt7623n_evb_fwu_defconfig";
})
