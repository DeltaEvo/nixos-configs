{ config, lib, pkgs, ... }:

{
	imports = [
		<nixpkgs/nixos/modules/installer/scan/not-detected.nix>
	];

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-uuid/eb01acce-79ff-4af6-b056-412ec8464956";
			fsType = "ext4";
		};
		"/boot" = {
			device = "/dev/disk/by-uuid/5642-7C77";
      		fsType = "vfat";
		};
		"/home" = {
			device = "/dev/disk/by-uuid/653d5f91-26ff-444b-8454-0f8a5092299e";
			fsType = "ext4";
		};
    };

	swapDevices = [
		{ device = "/dev/disk/by-uuid/6f2dcb7a-eb74-42ab-a452-833d79199ac8"; }
    ];

	boot.tmpOnTmpfs = true;

	boot.loader = {
		systemd-boot.enable = true;
		grub.device = "/dev/nvme0n1p1";
		efi.canTouchEfiVariables = true;
	};

	boot.initrd.luks.devices = [
		{
			name = "root";
			device = "/dev/nvme0n1p5";
			preLVM = true;
		}
		{
			name = "home";
			device = "/dev/sda1";
			preLVM = true;
		}
	];

	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci" ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = with pkgs.linuxPackages; [ tp_smapi ];

	# Remove unused blocks for SSD
	services.fstrim.enable = true;

	# UK Keyboard Layout
	i18n.consoleKeyMap = "uk";
	services.xserver.layout = "gb";
	services.xserver.xkbOptions = "compose:ralt";

	# Fingerprint device
	services.fprintd.enable = true;

	# Nvidia optimus
	hardware.bumblebee.enable = config.services.xserver.enable;
	services.xserver.videoDrivers = [ "modesetting" ];

	# Disable bluetooth it suck batery
	hardware.bluetooth.enable = false;

	nix.maxJobs = lib.mkDefault 4;
	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

	# Enable trackpoint and disable trackpad
	services.xserver.config = ''
		Section "InputClass"
			Identifier     "Enable libinput for TrackPoint"
			MatchIsPointer "on"
			Driver         "libinput"
		EndSection
	'';

    services.xserver.modules = [ pkgs.xorg.xf86inputlibinput ];
}