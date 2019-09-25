{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./home/base.nix
      ./home/vm.nix
      ./modules/base-minimal.nix
      ./modules/firewall.nix
      ./modules/networking.nix
      ./modules/workstation-light.nix
    ];

  battery = true;
  audio = false;
  backlight = false;
  realHardware = false;

  nix.buildMachines = [{
    hostName = "xps15.local";
    sshUser = "nixBuild";
    sshKey = "/root/id_rsa.build";
    system = "x86_64-linux";
    speedFactor = 4;
    supportedFeatures = [ "big-parallel" ];
    maxJobs = 4;
  }];
  nix.distributedBuilds = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.initrd.checkJournalingFS = false;
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];

  services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --dpi 144
  '';

  services.xserver.videoDrivers = ["vboxvideo"];
  nix.maxJobs = lib.mkDefault 2;
  virtualisation.virtualbox.guest.enable = true;

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };

  networking.hostName = "surface";

  # i18n.consoleFont = "latarcyrheb-sun32";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/badde61f-b85e-4e2f-814f-04d1b11e9150";
      fsType = "ext4";
    };

  swapDevices = [];
}
