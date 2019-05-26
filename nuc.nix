# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/initrd-ssh.nix
      ./modules/firewall.nix
      ./modules/syncthing.nix
      # ./modules/networking.nix
      # ./modules/transmission.nix
      ./modules/base.nix
      ./modules/efi.nix
      ./modules/home-manager
    ];

  networking = {
    hostName = "nuc";
    interfaces.eth0.useDHCP = true;
    wireless = {
      enable = true;
      userControlled = true;
    };
    firewall.allowedTCPPorts = [ 139 445 9091 ];
    firewall.allowedUDPPorts = [ 137 138 ];
  };

  services.btrfs = {
    autoScrub = {
      fileSystems = [ "/mnt/data" ];
    };
  };

  i18n.consoleFont = "latarcyrheb-sun32";

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

  boot = {
    # kernelParams = [ "ip=:::::enp0s25:dhcp::"];

    initrd = {
      availableKernelModules = [ "e1000e" "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      luks.devices = [
        {
          name = "root";
          device = "/dev/disk/by-uuid/02ffb944-cf2d-49c3-bbb3-21689fca0cb1";
          allowDiscards = true;
        }
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  programs.mosh.enable = true;

  services.openssh = {
    kexAlgorithms = ["curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256" "diffie-hellman-group14-sha1"];
    macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" "umac-128-etm@openssh.com" "hmac-sha2-512" "hmac-sha2-256" "umac-128@openssh.com" "hmac-sha1"];
  };

  # services.transmission.settings = {
  #   download-dir = "/mnt/data/repos/Media/Downloads";
  #   incomplete-dir = "/mnt/data/repos/Media/Downloads/.incomplete";
  #   incomplete-dir-enabled = true;
  #   rpc-whitelist = "*";
  #   rpc-whitelist-enabled = true;
  #   rpc-host-whitelist = "*";
  #   rpc-host-whitelist-enabled = true;
  #   peer-port-random-on-start = true;
  # };

  services.samba = {
    enable = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = server
      netbios name = server
      guest account = nobody
      map to guest = bad user
      follow symlinks = yes
    '';
    shares = {
      media = {
        path = "/mnt/data/repos/Media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "silvio";
        "force group" = "users";
      };
      music = {
        path = "/mnt/data/repos/Music";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "silvio";
        "force group" = "users";
      };
    };
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e6cd25e3-2b6c-483c-8b61-48d2456704a9";
      fsType = "btrfs";
      options = [ "subvol=@nixos" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/e6cd25e3-2b6c-483c-8b61-48d2456704a9";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/572B-2537";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/06019a74-dd06-4ef6-87a2-308016edacdf"; }
    ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";
}
