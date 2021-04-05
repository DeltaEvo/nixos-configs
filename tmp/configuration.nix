# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  bpiWirelessTools = pkgs.callPackage ./pkgs/bpi {};
  bpiWirelessFirmware = pkgs.callPackage ./pkgs/bpi/firmware.nix {};
  cozy = pkgs.callPackage ./pkgs/cozy {};
in
{

  imports = [
    ./modules/coredns.nix
    ./modules/traffic-shaping.nix
  ];
 
  nixpkgs.config.allowUnfree = true;

  nix.maxJobs = lib.mkDefault 4;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "bpi";
    nameservers = ["127.0.0.1"];
    bridges."br.lan" = {
      interfaces = [
        "lan0"
        "lan1"
        "lan2"
        "lan3"
        "wlp1s0"
      ];
    };
    interfaces = {
      "wan".useDHCP = true;
      "br.lan".ipv4.addresses = [{
        address = "192.168.0.1";
        prefixLength = 24;
      }];
    };
    nat = {
      enable = true;
      internalInterfaces = ["br.lan"];
      internalIPs = ["192.168.0.0/24"];
      externalInterface = "wan";
    };
    useNetworkd = true;
    firewall.trustedInterfaces = ["br.lan"];
    trafficShaping = {
      enable = false;
      wanInterface = "wan";
      lanInterface = "br.lan";
      lanNetwork = "192.168.0.0/24";
      maxDown = "3mbit";
      maxUp = "1mbit";
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/30904#issuecomment-445073924
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online -i wan -i br.lan"
  ];

  services.resolved.enable = false;
  
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./linux-bpir2-4.14.nix {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.modinst_arg_list_too_long
    ];
  });

  boot.kernelPatches = [ {
    name = "ath5k-config";
    patch = null;
    extraConfig = ''
      WLAN_VENDOR_ATH y
      ATH5K_PCI y
    '';
  } ];

  boot.cleanTmpDir = true;

  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/mmcblk0p1";
      fsType = "ext4";
    };
  };

  # systemd.services.stp-uart-launcher = {
  #  description = "BPI stp_uart_launcher service";
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    ExecStartPre = "-${bpiWirelessTools}/bin/wmt_loader";
  #    ExecStart = "${bpiWirelessTools}/bin/stp_uart_launcher -p ${bpiWirelessFirmware}";
  #  };
  #};

  #systemd.services.bpi-ap0 = {
  #  description = "BPI ap0 interface";
  #  serviceConfig = {
  #    Type = "oneshot";
  #    ExecStart = "${pkgs.bash}/bin/bash -c \"sleep 5; echo A > /dev/wmtWifi\"";
  #  };
  #};

  #systemd.paths.bpi-ap0 = {
  #  description = "BPI ap0 interface";
  #  wantedBy = [ "multi-user.target" ];
  #  pathConfig = {
  #    PathExists = "/dev/wmtWifi";
  #  };
  #};

  services.hostapd = {
    enable = true;
    interface = "wlp1s0";
    ssid = "Licorne";
    wpaPassphrase = "gomhuredjidciewg9ogi"; 
    channel = 11;
    extraConfig = ''
      bridge=br.lan
    '';
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    pciutils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  nixpkgs.config.packageOverrides = pkgs: rec {
    cups = pkgs.cups.overrideAttrs (attrs: {
      patches = attrs.patches ++ [
	./airprint-support.patch
      ];
    });
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = ["192.168.0.1:631"];
  services.printing.drivers = with pkgs; [ brlaser gutenprint ];
  services.printing.defaultShared = true;
  services.printing.extraConf = ''
    ServerAlias cups.home.delta.sh
    <Location />
      Allow all
    </Location>

    <Location /admin>
      Allow all
    </Location>

    <Location /admin/conf>
      Allow all
    </Location>
  '';

  systemd.services.cloud-print-connector = {
    description = "Google Cloud Print Connector";
    documentation = ["https://github.com/google/cloud-print-connector"];
    wantedBy = [ "multi-user.target" ];
    after = [ "cups.service" "avahi.service" "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloud-print-connector}/bin/gcp-cups-connector -config-filename ${./gcp-cups-connector.config.json}";
      Restart = "on-failure";
      User = "cloud-print-connector";
    };
  };

  users.users.cloud-print-connector = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/cloud-print-connector";
    group = "cloud-print-connector";
  };

  users.groups.cloud-print-connector = {};

  systemd.services.cozy = {
    description = "Cozy cloud";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [imagemagick];
    serviceConfig = {
      ExecStart = "${cozy}/bin/cozy-stack serve --fs-url file://localhost/var/lib/cozy";
      Restart = "on-failure";
      User = "cozy";
    };
  };

  users.users.cozy = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/cozy";
    group = "cozy";
  };

  users.groups.cozy = {};

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # Open ports in the firewall.

  services.coredns = {
    enable = true;
    config = ''
      home.delta.sh. {
        template IN A {
          answer "{{ .Name }} 60 IN A 192.168.0.1"
        }
      }
      . {
        log
        errors
        prometheus
        cache
        loadbalance round_robin
        forward . 9.9.9.9 149.112.112.112 {
          policy sequential
        }
      }
    '';
    package = (pkgs.callPackage ./pkgs/coredns {});
  };

  services.aria2.enable = true;
  services.minio.enable = true;

  services.grafana.enable = true;
  services.grafana.rootUrl = "http://grafana.home.delta.sh";
  services.grafana.package = (pkgs.callPackage ./grafana.nix {});

  # services.mongodb.enable = true;
  services.telegraf.enable = true;
  services.telegraf.extraConfig = {
    outputs = {
      influxdb = {
        urls = ["http://localhost:8086"];
        database = "telegraf";
      };
    };
    inputs = {
      cpu = {
        percpu = true;
      };
      mem = {};
      system = {};
      swap = {};
      disk = {
        ignore_fs = ["tmpfs" "devtmpfs" "devfs" "overlay" "aufs" "squashfs"];
      }; 
      exec = {
        commands = ["cat /sys/class/thermal/thermal_zone0/temp"];
        name_override = "temp";
        data_format = "value";
        data_type = "integer";
      };
      prometheus = {
        urls = ["http://localhost:9153/metrics" "http://localhost:6060/metrics"];
      };
    };
  };
  services.influxdb.enable = true;
  services.influxdb.extraConfig.collectd = [{
    enabled = false;
  }];


  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    virtualHosts."grafana.home.delta.sh" = {
      locations."/".proxyPass = "http://127.0.0.1:3000/";
    };
    virtualHosts."*.cozy.home.delta.sh" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080/";
        proxyWebsockets = true;
      };
    };
    virtualHosts."cups.home.delta.sh" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.0.1:631/";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
          add_header Access-Control-Allow-Headers "Authorization, Content-Type";
        '';
      };
    };
  };

  systemd.services.nginx.after = [ "acme-cups.home.delta.sh.service"];

  security.acme.certs = {
    "cups.home.delta.sh" = {
      email = "deltaduartedavid@gmail.com";
      dnsProvider = "cloudflare";
      credentialsFile = "/etc/nixos/cloudflare-credentials";
    };
  };

  services.postgresql = {
    enable = true;
  };

  services.couchdb = {
    enable = true;
    package = pkgs.callPackage <nixpkgs/pkgs/servers/http/couchdb/2.0.0.nix> {
      erlang = pkgs.erlang_nox;
      spidermonkey = pkgs.spidermonkey_1_8_5;
    };
  };

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      #option domain-name "lan";

      #ddns-updates on;
      #ddns-update-style interim;
      #ignore client-updates;
      #update-static-leases on;


      #zone lan. {
      #  primary 127.0.0.1;
      #}

      #zone 1.168.192.in-addr.arpa. {
      #  primary 127.0.0.1;
      #}

      option domain-name-servers 192.168.0.1;
      option routers 192.168.0.1;

      option subnet-mask 255.255.255.0;
      option broadcast-address 192.168.0.255;
      subnet 192.168.0.0 netmask 255.255.255.0 {
        range 192.168.0.100 192.168.0.200;
      }
    '';
    interfaces = ["br.lan"];
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

  users.extraUsers.david = {
    isNormalUser = true;
    home = "/home/david";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDowHs9CSn76pFw8l5p0uI27hiZB/ZuV1aEeVrDoqjRvNFAs9jy6KzHk8E85+VckfaDv+u2ZQA4NtJHW+PIntrbeCz06soTspMqFUbZ5ombR8ywwlJhKsS0aDwtNpPHhvzv3A1+Vkbp1pI4p40IT5li48WBDQ4f5UTW81WK96XZpw2dW7RDiWNDoH848nBbhE+NY7TcmlI1czQPbuAsH0Sl/nYxEoTUU/I7UwBIcZpvVl/qs3uE4qSaaWR9O+LXKnvpr/F5RMTcIEg5q7qK442rOPn2o+9Qwwm7sttTLYIFyrZa+wZYMjzB/FWGHIqtWb4lZZEJSEvR+ji6u1FpCiBZ deltaduartedavid@gmail.com"];
  };

  programs.fish.enable = true;
  programs.mosh.enable = true;

  hardware.enableRedistributableFirmware = true;

  services.gitea.enable = true;
}
