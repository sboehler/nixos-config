{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/base.nix
      ./modules/buildmachine.nix
      ./modules/efi.nix
      ./modules/firewall.nix
      ./modules/laptop.nix
      ./modules/mbsyncd.nix
      ./modules/networking.nix
      ./modules/syncthing.nix
      ./modules/virtualbox.nix
      ./modules/transmission.nix
      ./modules/workstation.nix
    ];

  battery = true;
  backlight = true;

  boot = {
    kernelParams = [ "acpi_rev_override=1"
                     "pcie_aspm=off"
                     "i915.enable_fbc=1"
                     "i915.enable_rc6=1"
                     "i915.fastboot=1"
                     "i915.disable_power_well=0"
                     "i915.enable_psr=1"
                   ];

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
          device = "/dev/disk/by-uuid/5ab08dff-ce9b-4b1e-ad34-168f36fde4c8";
          allowDiscards = true;
        }
      ];
    };
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
      options iwlwifi power_save=Y
      options iwldvm force_cam=N
    '';
  };

  services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --dpi 192
  '';

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };


  networking = {
    hostName = "xps15";
    hostId = "1e9f9fca";
  };

  services.tlp = {
    extraConfig = ''
      DISK_DEVICES="nvme0n1";
    '';
  };

  i18n.consoleFont = "latarcyrheb-sun32";

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
    # pkgs.linuxPackages.nvidia_x11.out
  ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
  };



  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fbed58ae-791d-4523-ab90-6a30c9471a15";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9E4C-49CF";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/fbed58ae-791d-4523-ab90-6a30c9471a15";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  nix.maxJobs = lib.mkDefault 8;
}
