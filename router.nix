# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/firewall.nix
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

  fileSystems."/mnt/data" =
    { device = "/dev/mapper/data";
      fsType = "btrfs";
      options = [
        "noauto"
        "subvol=@data"
      ];
    };

  environment.etc = {
    "crypttab" = {
      enable = true;
      text = ''
        data UUID=02ffb944-cf2d-49c3-bbb3-21689fca0cb1 none noauto
      '';
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/e1346b73-6dc9-c943-9a52-7c3677215e4f";
      randomEncryption = true;
    }
  ];

  environment.systemPackages = with pkgs; [
    (writeScriptBin "data-mount" ''
      ${pkgs.systemd}/bin/systemctl start mnt-data.mount
    '')
    (writeScriptBin "data-umount" ''
      ${pkgs.systemd}/bin/systemctl stop systemd-cryptsetup@data
    '')
  ];


  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";

  systemd = {

    # parse crypttab and generate systemd units
    packages = [ pkgs.systemd-cryptsetup-generator ];

    services = {
      onedrive = {
        serviceConfig = {
          ExecStart = "${pkgs.rclone}/bin/rclone --config /mnt/data/config/rclone.conf sync --transfers=16 onedrive: /mnt/data/onedrive";
          Type = "oneshot";
          User = "silvio";
        };
        unitConfig = {
          After="mnt-data.mount";
          Requisite="mnt-data.mount";
        };
      };

      restic-backups-onedrive-b2 = {
        unitConfig = {
          After="onedrive.service mnt-data.mount";
          Requires="onedrive.service";
          Requisite="mnt-data.mount";
        };
      };
    };
  };

  services = {
    restic = {
      backups = {
        onedrive-b2 = {
          passwordFile = "/mnt/data/config/restic-b2-data";
          s3CredentialsFile = "/mnt/data/config/restic-b2-data-credentials";
          user = "silvio";
          paths = ["/mnt/data/onedrive"];
          repository = "b2:restic-smb:repos";
          extraOptions = ["b2.connections=25"];
          extraBackupArgs = [ "--verbose" ];
          timerConfig = {
            OnCalendar = "*-*-* 04:00:00";
            Persistent = true;
          };
        };
      };
    };
  };
}
