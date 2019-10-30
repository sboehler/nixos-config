# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
#      ./modules/initrd-ssh.nix
      ./modules/firewall.nix
#      ./modules/syncthing.nix
#      ./modules/mbsyncd.nix
#      ./modules/transmission.nix
      ./modules/base.nix
#      ./modules/nuc-backup.nix
      ./modules/efi.nix
#      ./modules/wireguard-server.nix
    ];

  networking = {
    hostName = "router";
    hostId = "e110e344";
    useDHCP = false;
    enableIPv6 = true;
    wireless = {
      enable = false;
      userControlled = true;
    };
#    firewall.allowedTCPPorts = [ 139 445 9091 ];
#    firewall.allowedUDPPorts = [ 137 138 ];
    interfaces = {
      enp0s31f6 = {
        useDHCP = true;
      };
    };
  };

 # i18n.consoleFont = "latarcyrheb-sun32";

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" "rtsx_usb_sdmmc" ];
    };
    kernelModules = [ "kvm-intel" ];
  };

#  programs.mosh.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/87526952-e44d-4d7c-af43-4a2bd73b73db";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B538-D20A";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/87526952-e44d-4d7c-af43-4a2bd73b73db";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
  };

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";
}
