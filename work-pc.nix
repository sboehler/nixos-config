{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/firewall.nix
      ./modules/mbsyncd.nix
      ./modules/networking.nix
      ./modules/syncthing.nix
      ./modules/workstation.nix
      ./modules/home-manager
      ./modules/tw-backup.nix
      ./modules/twjava
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
          device = "/dev/disk/by-uuid/1c97e01d-768c-4a5f-a60c-fb80af1d1dd5";
          allowDiscards = true;
        }
      ];
    };
  };

  networking.hostName = "worky-mcworkface";

  virtualisation.virtualbox.host.enable = true;

  services.btrfs.autoScrub = {
    fileSystems = ["/mnt/data"];
  };

  fonts.fontconfig = {
    dpi = 132;
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
    dpi = 132;
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

  environment.variables = {
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };


  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ae2bf910-85a4-4fba-928a-bc15619473f6";
    fsType = "btrfs";
    options = ["subvol=@root" "compress=lzo"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4EE8-0469";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ae2bf910-85a4-4fba-928a-bc15619473f6";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=lzo"];
  };

  fileSystems."/mnt/data" = {
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/0d043065-e96a-45ec-a43f-2116a9e3070e";
      keyFile = "/mnt-root/root/sdb_key";
      label = "data";
    };
    device = "/dev/mapper/data";
    fsType = "btrfs";
    options = ["compress=lzo"];
  };

  swapDevices = [{
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_512GB_S42YNF0K914671W-part2";
    randomEncryption = true;
  }];

  nix.maxJobs = lib.mkDefault 8;
}
