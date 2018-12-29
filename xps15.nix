{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/buildmachine.nix
      ./modules/laptop.nix
      ./modules/mbsyncd.nix
      ./modules/syncthing.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
    ];


  boot = {
    kernelParams = [ "acpi_rev_override=1"];

    kernelModules = [ "kvm-intel" ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_4_19;

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/nvme0n1p2";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  networking = {
    hostName = "xps15";
  };

  services.tlp = {
    extraConfig = ''
      DISK_DEVICES="nvme0n1";
    '';
  };

  i18n.consoleFont = "latarcyrheb-sun32";

  services.transmission = {
    enable = true;
  };

  hardware.bumblebee = {
    enable = true;
    driver = "nvidia";
  };

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = [
    pkgs.vaapiIntel
    pkgs.libvdpau-va-gl
    pkgs.vaapiVdpau
    pkgs.intel-ocl
    pkgs.linuxPackages.nvidia_x11.out
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/270eb045-3b47-4cc4-b8a2-07ec6eb5bada";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1AB0-19EF";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/270eb045-3b47-4cc4-b8a2-07ec6eb5bada";
      fsType = "btrfs";
      options = [ "subvol=@nixos-home" ];
    };

  swapDevices = [{
    device = "/dev/disk/by-uuid/901a64b3-d8dc-4745-b3d7-cfca564b7c9c";
  }];

  system.stateVersion = "18.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 8;
}
