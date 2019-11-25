# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  nixpkgs = {
    config = {
      packageOverrides = pkgs: rec {
        dhcpcd = pkgs.dhcpcd.overrideAttrs (oldAttrs: rec {
          patches = [
            # make it work with init7
            ./dhcpcd.patch
          ];
        });
      };
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./modules/sys/firewall.nix
      ./modules/sys/efi.nix
      ./modules/base.nix
      ./modules/home/base.nix
    ];

  networking = {
    hostName = "router";
    hostId = "e110e344";
    hosts = { "10.0.0.1" = [ "router" ]; };
    useDHCP = false;
    enableIPv6 = true;
    dhcpcd = {
      extraConfig = ''
        debug
        noipv6rs
        interface enp0s31f6
          ipv6rs
          ia_na 1
          ia_pd 2 enp1s0
      '';
    };
    wireless = {
      enable = false;
      userControlled = true;
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "enp1s0" "wg0" ];
      interfaces = {
        enp0s31f6 = {
          allowedUDPPorts = [ 51820 ];
        };
      };
      extraCommands = ''
        iptables -A FORWARD -i wg0 -j ACCEPT
        iptables -A FORWARD -o wg0 -j ACCEPT
      '';
    };

    interfaces = {
      enp0s31f6 = {
        useDHCP = true;
        preferTempAddress = true;
      };
      enp1s0 = {
        preferTempAddress = false;
        ipv4 = {
          addresses = [{
            address = "10.0.0.1";
            prefixLength = 24;
          }];
        };
      };
    };

    nat = {
      enable = true;
      externalInterface = "enp0s31f6";
      internalInterfaces = ["enp1s0" "wg0" ];
      internalIPs = [ "10.0.0.0/24" "10.0.1.0/24" ];
    };

    wireguard = {
      interfaces = {
        wg0 = {
          ips = ["10.0.1.1/24"];
          listenPort = 51820;
          privateKeyFile = "/home/silvio/wireguard-keys/private";
          peers = [
            {
              # Phone
              publicKey = "imUVLCuhttorPeRmSHDfoRI8t07wB9RAgp5VAVTgHgw=";
              allowedIPs = [ "10.0.1.0/24" ];
            }
            {
              # Surface
              publicKey = "DbPYec00eG1MIbl53W+JNRJpIYt/xDk0+4NczHNTbk0=";
              allowedIPs = [ "10.0.1.0/24" ];
            }
          ];
        };
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
    kernel = {
      sysctl = {
        "net.ipv6.conf.enp0s31f6.accept_ra" = 2;
        "net.ipv6.conf.all.forwarding" = true;
      };
    };
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
    dnsmasq
  ];

  nix.maxJobs = 2;
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
        after=["mnt-data.mount"];
        requisite=["mnt-data.mount"];
      };

      restic-backups-onedrive-b2 = {
        after=["onedrive.service" "mnt-data.mount"];
        requires=["onedrive.service"];
        requisite=["mnt-data.mount"];
      };
    };
  };

  services = {

    dnsmasq = {
      enable = true;
      alwaysKeepRunning = true;
      resolveLocalQueries = true;
      extraConfig = ''
        domain-needed
        bogus-priv
        filterwin2k
        expand-hosts
        domain=lan
        local=/lan/
        enable-ra
        localise-queries
        except-interface=enp0s31f6
        dhcp-range=::,constructor:enp1s0,ra-stateless,ra-names
        dhcp-range=10.0.0.2,10.0.0.200
        dhcp-lease-max=100
        dhcp-option=option:router,10.0.0.1
        dhcp-authoritative
      '';
    };

    ddclient = let
      secrets = import ./secrets/ddclient.crypt.nix;
    in {
      enable = true;
      server = "freemyip.com";
      username = secrets.token;
      password = secrets.token;
      domains = [ secrets.domain ];
      protocol = "dyndns2";
    };

    samba = {
      enable = true;
      extraConfig = ''
      workgroup = WORKGROUP
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
