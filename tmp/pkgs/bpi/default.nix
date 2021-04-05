{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "bpi-r2-wireless-tools-${version}";
  version = "1.0";

  srcs = [
    (fetchurl {
      name = "wmt_ioctl.h";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/tools/src/wmt_ioctl.h";
      sha256 = "6c953a68cd3a82f148a02070d7d3b0b71147479910cb94d4d5941e740f9abb0d";
    })
    (fetchurl {
      name = "stp_uart_launcher.c";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/tools/src/stp_uart_launcher.c";
      sha256 = "35cc80590fcfeb0e5b5d2ce8c2b4432b2d8d433cfabde8fd1db644971214e238";
    })
    (fetchurl {
      name = "wmt_loader.c";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/tools/src/wmt_loader.c";
      sha256 = "18fe6a2d79d7ba3c5c780eaaa0839276900199786e77a41df9a97a13efe44d15";
    })
    (fetchurl {
      name = "wmt_loopback.c";
      url = "https://raw.githubusercontent.com/BPI-SINOVOIP/BPI-R2-bsp/6b9512b853b1efc66109a41a0108579dcc9e054c/vendor/mediatek/connectivity/tools/src/wmt_loopback.c";
      sha256 = "11dffd9baefa24d4cf3f24ff4b86f11336ce1efe7dbab81a9ca2618583f9759b";
    })
  ];

  unpackPhase = ''
    for src in $srcs; do
      cp $src `echo $src | cut -d- -f2-`
    done
  '';
  sourceDir = ".";

  buildPhase = ''
    gcc stp_uart_launcher.c -lpthread -o stp_uart_launcher
    gcc wmt_loopback.c -o wmt_loopback
    gcc wmt_loader.c -o wmt_loader
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp stp_uart_launcher $out/bin
    cp wmt_loopback $out/bin
    cp wmt_loader $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Tool to enable wireless on BPI r2";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ deltaevo ];
  };
}
