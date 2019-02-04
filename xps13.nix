{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/firewall.nix
      ./modules/laptop.nix
      ./modules/mbsyncd.nix
      ./modules/networking.nix
      ./modules/syncthing.nix
      ./modules/transmission.nix
      ./modules/workstation.nix
    ];


  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [
        "intel_agp"
        "i915"
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
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  services.tlp = {
    extraConfig = ''
      DISK_DEVICES="nvme0n1";
    '';
  };

  networking.hostName = "xps13";

  i18n.consoleFont = "latarcyrheb-sun32";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a6bd768c-b7aa-4101-9c05-9506979ff5f9";
      fsType = "btrfs";
      options = [ "subvol=@nixos" "space_cache" "noatime"];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/a6bd768c-b7aa-4101-9c05-9506979ff5f9";
      fsType = "btrfs";
      options = [ "subvol=@nixos_home" "space_cache" "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/E8B5-40A9";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/d6707d20-eb42-4e3a-8dff-31fa02af3b89";
  }];

  nix.maxJobs = lib.mkDefault 4;
}
