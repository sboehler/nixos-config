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
      ./modules/mbsyncd.nix
      ./modules/transmission.nix
      ./modules/base.nix
      ./modules/nuc-backup.nix
      ./modules/efi.nix
      ./modules/wireguard-server.nix
    ];

  networking = {
    hostName = "nuc";
    hostId = "e110e344";
    usePredictableInterfaceNames = false;
    useDHCP = true;
    enableIPv6 = true;
    wireless = {
      enable = true;
      userControlled = true;
    };
    firewall.allowedTCPPorts = [ 139 445 9091 ];
    firewall.allowedUDPPorts = [ 137 138 ];
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

  services.transmission.settings = {
    incomplete-dir-enabled = true;
    rpc-whitelist = "*";
    rpc-whitelist-enabled = true;
    rpc-host-whitelist = "*";
    rpc-host-whitelist-enabled = true;
    peer-port-random-on-start = true;
  };

  services.samba = {
    enable = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = server
      netbios name = nuc
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
      lightroom = {
        path = "/mnt/data/lightroom";
        browseable = "yes";
        "valid users" = "silvio";
        "read only" = "no";
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

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-uuid/e6cd25e3-2b6c-483c-8b61-48d2456704a9";
      fsType = "btrfs";
      options = [ "subvol=@data" ];
    };

  systemd.generator-packages = [ pkgs.systemd-cryptsetup-generator ];
  environment.etc = {
    "crypttab" = {
      enable = true;
      text = ''
       backup UUID=b4c624a8-97f4-418b-a6df-43ca5922b40f /root/keyfile_backup noauto
      '';
    };
  };

  fileSystems."/mnt/backup" =
    { device = "/dev/mapper/backup";
      fsType = "btrfs";
      options = ["nofail" "x-systemd.device-timeout=1ms"];
    };

  swapDevices =
    [ {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_QVO_4TB_S4CXNF0M310137V-part2";
      randomEncryption = true;
    }
    ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";
}
