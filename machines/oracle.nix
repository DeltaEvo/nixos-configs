{ pkgs, config, ... }: {

  imports = [ ../hardware/oracle_compute.nix ../common.nix ];

  networking.hostName = "Oracle";

  # Disable bluetooth it suck batery
  hardware.bluetooth.enable = false;

  home-manager.useGlobalPkgs = true;

  security.sudo.wheelNeedsPassword = false;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDowHs9CSn76pFw8l5p0uI27hiZB/ZuV1aEeVrDoqjRvNFAs9jy6KzHk8E85+VckfaDv+u2ZQA4NtJHW+PIntrbeCz06soTspMqFUbZ5ombR8ywwlJhKsS0aDwtNpPHhvzv3A1+Vkbp1pI4p40IT5li48WBDQ4f5UTW81WK96XZpw2dW7RDiWNDoH848nBbhE+NY7TcmlI1czQPbuAsH0Sl/nYxEoTUU/I7UwBIcZpvVl/qs3uE4qSaaWR9O+LXKnvpr/F5RMTcIEg5q7qK442rOPn2o+9Qwwm7sttTLYIFyrZa+wZYMjzB/FWGHIqtWb4lZZEJSEvR+ji6u1FpCiBZ deltaduartedavid@gmail.com"
  ];
}
