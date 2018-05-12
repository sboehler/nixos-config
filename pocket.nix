{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/networking.nix
      ./modules/wifi.nix
      ./modules/laptop.nix
      ./modules/resolved.nix
      ./modules/workstation.nix
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/broadcom
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      linux_testing = pkgs.linux_testing.override {
        extraConfig = ''
          ACPI_CUSTOM_METHOD m
          B43_SDIO y

          BATTERY_MAX17042 m

          COMMON_CLK y

          INTEL_SOC_PMIC? y
          INTEL_SOC_PMIC_CHTWC? y
          INTEL_PMC_IPC m
          INTEL_BXTWC_PMIC_TMU m

          ACPI y
          PMIC_OPREGION y
          CHT_WC_PMIC_OPREGION? y
          XPOWER_PMIC_OPREGION y
          BXT_WC_PMIC_OPREGION y
          CHT_DC_TI_PMIC_OPREGION y
          XPOWER_PMIC_OPREGION y

          MATOM y

          PINCTRL_CHERRYVIEW y

          DW_DMAC y
          DW_DMAC_CORE y
          DW_DMAC_PCI y

          GPD_POCKET_FAN y

          HSU_DMA y

          I2C y
          I2C_CHT_WC y
          I2C_DESIGNWARE_BAYTRAIL? y

          INTEL_CHT_INT33FE m
          MFD_AXP20X m
          TYPEC_MUX_PI3USB30532 m
          #MUX_INTEL_CHT_USB_MUX m
          # MUX_PI3USB30532 m
          NVRAM y
          POWER_RESET y
          PWM y
          PWM_LPSS m
          PWM_LPSS_PCI m
          PWM_LPSS_PLATFORM m
          PWM_SYSFS y
          RAW_DRIVER y
          RTC_DS1685_SYSFS_REGS y
          SERIAL_8250_DW y
          SERIAL_8250_MID y
          SERIAL_8250_NR_UARTS 32
          SERIAL_8250_PCI m
          SERIAL_DEV_BUS y
          SERIAL_DEV_CTRL_TTYPORT y
          TOUCHSCREEN_ELAN m
          TULIP_MMIO y
          W1_SLAVE_DS2433_CRC y
          XXHASH m

          INTEL_INT0002_VGPIO m
          REGULATOR y
          TYPEC m
          TYPEC_TCPM m
          TYPEC_FUSB302 m

          BATTERY_MAX17042 m
          CHARGER_BQ24190 m
          # EXTCON m
          # EXTCON_INTEL m
          EXTCON_INTEL_CHT_WC m
        '';
      };
    };
  };

  boot = {
    kernelParams = [
      "i915.enable_rc6=1"
      "i915.enable_fbc=1"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_testing;

    initrd = {
      kernelModules = [
        "pwm-lpss"
        "pwm-lpss-platform" # for brightness control
        "g_serial" # be a serial device via OTG
        "bq24190_charger"
        "i915"
        "fusb302"
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
  };

  networking.hostName = "pocket";

  i18n.consoleFont = "latarcyrheb-sun32";

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    MOZ_USE_XINPUT2 = "1";
  };

  nix.buildMachines = [{
    hostName = "xps15";
    sshUser = "nixBuild";
    sshKey = "/root/id_rsa.build";
    system = "x86_64-linux";
    speedFactor = 4;
    supportedFeatures = [ "big-parallel" ];
    maxJobs = 4;
  }];
  nix.distributedBuilds = true;

  services.xserver = {
    dpi = 200;
    displayManager.sessionCommands = ''
      xrdb "${pkgs.writeText "xrdb.conf" ''
        Xft.dpi: 200
        Xcursor.theme: Vanilla-DMZ
        Xcursor.size: 48
      ''}"
      '';
      videoDrivers = [ "intel" ];
      useGlamor = true;
      xrandrHeads = [
        {
          output = "DSI1";
          primary = true;
          monitorConfig = ''
            Option "Rotate" "right"
          '';
        }
      ];
      inputClassSections = [
        ''
          Identifier	"calibration"
          MatchProduct	"Goodix Capacitive TouchScreen"
          Option  	"TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
        ''
      ];
    };

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

  swapDevices = [];

  system.stateVersion = "18.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 1;
}
