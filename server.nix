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
      ./modules/transmission.nix
      ./modules/base.nix
      ./modules/bios.nix
      ./modules/home-manager
    ];

  # Use the GRUB 2 boot loader.
  # boot.vesa = true;
  networking = {
    hostName = "server";
    enableIPv6 = true;
    interfaces.eth0.useDHCP = true;
    firewall.allowedTCPPorts = [ 139 445 9091 ];
    firewall.allowedUDPPorts = [ 137 138 ];
  };

  services.btrfs = {
    autoScrub = {
      fileSystems = [ "/mnt/data" ];
    };
  };

  i18n.consoleFont = "Lat2-Terminus16";

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

  boot = {
    kernelParams = [ "ip=dhcp"];

    initrd = {
      availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_atiixp" "usb_storage" "usbhid" "sd_mod" "radeon" ];
      kernelModules = ["tg3"];
      luks.devices = [
        {
          name = "root";
          device = "/dev/disk/by-uuid/039faf14-9efc-4afc-a244-8284cbf7f212";
          preLVM = true;
          allowDiscards = true;
        }
      ];
      postMountCommands = ''
        # cryptsetup luksOpen --key-file /mnt-root/root/data_keyfile /dev/disk/by-uuid/af15ec68-4c42-4468-b74f-5c63288d5670 data1
        # cryptsetup luksOpen --key-file /mnt-root/root/data_keyfile /dev/disk/by-uuid/cb7824f0-2f90-45cc-8584-702fc16f9cd6 data2
        cryptsetup luksOpen --key-file /mnt-root/root/data_keyfile /dev/disk/by-uuid/73bbc691-046e-43ed-ae1e-360d43168047 data3
        cryptsetup luksOpen --key-file /mnt-root/root/data_keyfile /dev/disk/by-uuid/aeb9807b-7888-4702-9870-43f838e3aa4a data4
      '';
    };
    kernelModules = [ "kvm-amd" ];
  };

  programs.mosh.enable = true;

  services.openssh = {
    kexAlgorithms = ["curve25519-sha256@libssh.org" "diffie-hellman-group-exchange-sha256" "diffie-hellman-group14-sha1"];
    macs = ["hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" "umac-128-etm@openssh.com" "hmac-sha2-512" "hmac-sha2-256" "umac-128@openssh.com" "hmac-sha1"];
  };

  services.transmission.settings = {
    download-dir = "/mnt/data/repos/Media/Downloads";
    incomplete-dir = "/mnt/data/repos/Media/Downloads/.incomplete";
    incomplete-dir-enabled = true;
    rpc-whitelist = "127.0.0.1,192.168.2.*";
    rpc-host-whitelist = "*";
  };

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

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/541e5627-a3c2-4b6c-ad0e-f87803eb52af";
      fsType = "btrfs";
      options = [ "subvol=@nixos" "compress=lzo" "noatime" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/541e5627-a3c2-4b6c-ad0e-f87803eb52af";
      fsType = "btrfs";
      options = [ "subvol=@nixos_home" "compress=lzo" "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/ce546526-b0e9-4cc2-950f-ca9f92fd9147";
      fsType = "ext4";
    };

    "/mnt/data" = {
      device = "/dev/mapper/data3";
      fsType = "btrfs";
      options = [ "compress=lzo" "noatime" ];
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a133db75-d57d-4b9c-8e1f-f4ce264b947c"; }
    ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";
}
