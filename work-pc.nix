{ pkgs, lib, config, ... }:

{
  imports =
    [
       <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
    ];


  boot = {
    kernelModules = [ "kvm-intel" ];

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
          device = "/dev/sda2";
          preLVM = true;
          allowDiscards = true;
        }
      ];
    };
  };

  networking.hostName = "tw-pc-silvio";

  services.syncthing = {
    enable = true;
    systemService = false;
  };

  virtualisation.virtualbox.host.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql100;
  };

  services.xserver = {
    dpi = 144;
    videoDrivers = ["nvidia"];
    xrandrHeads = [
      {
        output = "DP-1";
        primary = true;
      }
      {
        output = "HDMI-0";
        monitorConfig = "Option \"RightOf\" \"DP-1\"";
      }
    ];
  };

  systemd.generator-packages = [ pkgs.systemd-cryptsetup-generator ];

  environment.etc = {
    "crypttab" = {
      enable = true;
      text = ''
        data UUID=0d043065-e96a-45ec-a43f-2116a9e3070e /root/sdb_key luks
      '';
    };
  };


  fileSystems."/" = {
    device = "/dev/disk/by-uuid/661bd881-7275-4f5e-80a4-08acdc97c2b3";
    fsType = "btrfs";
    options = ["subvol=@nixos"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FA68-ADEB";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/661bd881-7275-4f5e-80a4-08acdc97c2b3";
    fsType = "btrfs";
    options = ["subvol=@nixos_home"];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/mapper/data";
    fsType = "btrfs";
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/ca8083a2-a656-4f22-93cd-60912f3c90ab";
  }];

  system.stateVersion = "18.03"; # Did you read the comment?

  nix.maxJobs = lib.mkDefault 8;
}
