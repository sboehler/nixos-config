{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/firewall.nix
      ./modules/laptop.nix
      ./modules/mbsyncd.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/broadcom
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      linux_4_20 = pkgs.linux_4_20.override {
        extraConfig = ''
          B43_SDIO y

          PMIC_OPREGION y
          CHT_WC_PMIC_OPREGION y
          ACPI_I2C_OPREGION y

          I2C y
          I2C_CHT_WC m

          INTEL_SOC_PMIC_CHTWC y

          EXTCON_INTEL_CHT_WC m

          MATOM y
          I2C_DESIGNWARE_BAYTRAIL y
          POWER_RESET y
          PWM y
          PWM_LPSS m
          PWM_LPSS_PCI m
          PWM_LPSS_PLATFORM m
          PWM_SYSFS y
        '';
      };
    };
  };

  nix = {
    binaryCaches = [
      "ssh://xps15.local"
    ];
  };


  powerManagement = {
    enable = true;
    powerDownCommands = ''
      rmmod goodix
    '';
    powerUpCommands = ''
      modprobe goodix
    '';

  };

  services.tlp = {
    enable = true;
    extraConfig = ''
      DISK_DEVICES="mmcblk0"
      DISK_IOSCHED="deadline"

      WIFI_PWR_ON_AC=off
      WIFI_PWR_ON_BAT=off
    '';
  };

  boot = {
    kernelParams = [
      "gpd-pocket-fan.speed_on_ac=0"
    ];
    kernelModules = [ "kvm-intel" ];

    initrd = {
      kernelModules = [
        "intel_agp"
        "pwm-lpss"
        "pwm-lpss-platform" # for brightness control
        "i915"
      ];
      availableKernelModules = [
        "xhci_pci"
        "dm_mod"
        "btrfs"
        "crc23c"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_acpi"
        "rtsx_pci_sdmmc"
      ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/mmcblk0p2";
          preLVM = true;
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
    '';
  };

  networking.hostName = "pocket";

  i18n.consoleFont = "latarcyrheb-sun32";

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };

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

  # services.xserver = {
  #   xrandrHeads = [
  #     {
  #       output = "DSI1";
  #       primary = true;
  #       monitorConfig = ''
  #         Option "Rotate" "right"
  #       '';
  #     }
  #   ];
  #   deviceSection = ''
  #     Option "TearFree" "true"
  #   '';
  #   inputClassSections = [
  #     ''
  #       Identifier	  "calibration"
  #       MatchProduct	"Goodix Capacitive TouchScreen"
  #       Option  	    "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
  #     ''
  #     ''
  #       Identifier      "GPD trackpoint"
  #       MatchProduct    "SINO WEALTH Gaming Keyboard"
  #       MatchIsPointer  "on"
  #       Driver          "libinput"
  #       Option          "ScrollButton" "3"
  #       Option          "ScrollMethod" "button"
  #       Option          "MiddleEmulation" "True"
  #       Option          "AccelSpeed" "1"
  #       Option  	      "TransformationMatrix" "3 0 0 0 3 0 0 0 1"
  #     ''
  #   ];
  # };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f9c1df0d-5bcf-448b-9684-1b0b6712f5e1";
    fsType = "btrfs";
    options = [ "subvol=@nixos" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6CA0-301F";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f9c1df0d-5bcf-448b-9684-1b0b6712f5e1";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/6c4af545-7c97-4c3e-8015-17d8103430fa";
  }];

  system.stateVersion = "18.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 4;
}
