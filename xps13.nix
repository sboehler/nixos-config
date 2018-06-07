{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/wifi.nix
      ./modules/buildmachine.nix
      ./modules/laptop.nix
      ./modules/resolved.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
    ];


  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
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
      options i915 enable_rc6=1 enable_fbc=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  networking.hostName = "xps13";

  i18n.consoleFont = "latarcyrheb-sun32";

  environment.systemPackages = with pkgs; [
    intel-ocl
  ];

  fonts.fontconfig.dpi = 168;
  services.xserver = {
    dpi = 168;
    displayManager.sessionCommands = ''
      xrdb -merge "${pkgs.writeText "xrdb.conf" ''
        Xcursor.theme: Vanilla-DMZ
        Xcursor.size: 48
      ''}"
    '';
  };

  fileSystems = {
    "/home/silvio/arch_home" = {
      device = "/dev/disk/by-uuid/a6bd768c-b7aa-4101-9c05-9506979ff5f9";
      fsType = "btrfs";
      options = [ "subvol=@home" "space_cache" "noatime" ];
    };

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

  system.stateVersion = "17.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 4;
}
