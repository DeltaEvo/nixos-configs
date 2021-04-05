{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "bpi-r2-wireless-tools-${version}";
  version = "1.0";

  srcs = [
    (fetchurl {
      name = "WMT_SOC.cfg";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/config/WMT_SOC.cfg";
      sha256 = "6da55395f5e39eb09b98fb9a5eb9d95be04b243b6ef8bde2161b007898d27cc3";
    })
    (fetchurl {
      name = "WIFI_RAM_CODE_7623";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/firmware/WIFI_RAM_CODE_7623";
      sha256 = "d94493f4467a5d5d01c252a765d1f22e109065aff7154c61883fede330ffad14";
    })
    (fetchurl {
      name = "ROMv2_lm_patch_1_0_hdr.bin";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/firmware/ROMv2_lm_patch_1_0_hdr.bin";
      sha256 = "65d510e153bcbb2f7bd374ef67bc364ae710a2685636c7f06b41d03039676aa0";
    })
    (fetchurl {
      name = "ROMv2_lm_patch_1_1_hdr.bin";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/firmware/ROMv2_lm_patch_1_1_hdr.bin";
      sha256 = "784e2f956d710dbdbb80e63905aa7af88b0f597ed7fc5b80fb052b554f19eec2";
    })
    (fetchurl {
      name = "WIFI";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/firmware/nvram/WIFI";
      sha256 = "703d268fec8612ff4fb083f1e73e0c9d20435c060d1c6a1641560e346359de4d";
    })
  ];

  unpackPhase = ''
    for src in $srcs; do
      cp $src `echo $src | cut -d- -f2-`
    done
  '';
  sourceDir = ".";

  installPhase = ''
    mkdir -p $out/nvram
    cp WMT_SOC.cfg $out
    cp WIFI_RAM_CODE_7623 $out
    cp ROMv2_lm_patch_1_0_hdr.bin $out
    cp ROMv2_lm_patch_1_1_hdr.bin $out
    cp WIFI $out/nvram
  '';

  meta = with stdenv.lib; {
    description = "Firmware to enable wireless on BPI r2";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ deltaevo ];
  };
}
