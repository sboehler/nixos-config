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
      ./modules/workstation.nix
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      bluez2 = pkgs.bluez.overrideAttrs(attrs: {
        configureFlage = attrs.configureFlags ++ ["--enable-deprecated"];
        doCheck = false;
        priority = 1;
      });
    };
  };



  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };

  hardware = {
    enableAllFirmware = true;
    firmware = [
      (pkgs.callPackage ./modules/surface-wifi.nix {})
    ];
    sensor.iio.enable = true;
  };

  boot = {
    kernelParams = [ "mem_sleep_default=deep"];

    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];

      luks.devices = [
        {
          name = "root";
          device = "/dev/nvme0n1p3";
          preLVM = true;
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
      options snd_hda_intel power_save=1
      options snd_ac97_codec power_save=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
      options ath10k_core skip_otp=yto
    '';
  };

  environment.systemPackages = with pkgs; [
  (bluez.overrideAttrs (attrs: {
    name = "bluez-compat";
    configureFlags = [ "--enable-deprecated" ] ++ attrs.configureFlags;
    }))

  ];

  services.tlp = {
    extraConfig = ''
      DISK_DEVICES="nvme0n1";
    '';
  };

  networking.hostName = "surface";

  # i18n.consoleFont = "latarcyrheb-sun32";
  # services.xserver.displayManager.gdm.wayland = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/71f51184-e4bc-4817-a732-3d7e869d7258";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/71f51184-e4bc-4817-a732-3d7e869d7258";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3075-AFB9";
      fsType = "vfat";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/961cdeb1-dd60-457c-b587-5310c8a10118"; }
    ];
}
