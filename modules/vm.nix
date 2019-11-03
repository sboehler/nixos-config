{ config, pkgs, lib, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports =
    [
      <home-manager/nixos>
      ./home/base.nix
      ./home/xorg.nix
    ];

  options = {
    hostHostName = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    nixpkgs = {
      config = {
        allowUnfree = true;

        packageOverrides = pkgs: rec {
          niv = (import sources.niv {}).niv;
          # lorri = (import sources.lorri {});

          xrdp-vsock = pkgs.xrdp.overrideAttrs (oldAttrs: rec {
            configureFlags = oldAttrs.configureFlags ++ ["--enable-vsock"];
            postInstall = oldAttrs.postInstall + ''
            # use vsock transport.
            sed -i_orig -e 's/use_vsock=false/use_vsock=true/g' $out/etc/xrdp/xrdp.ini
            # use rdp security.
            sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' $out/etc/xrdp/xrdp.ini
            # remove encryption validation.
            sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' $out/etc/xrdp/xrdp.ini
            # disable bitmap compression since its local its much faster
            sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' $out/etc/xrdp/xrdp.ini
          '';
          });
        };
      };
    };

    nix = {
      buildCores = 0;
      autoOptimiseStore = true;
      maxJobs = lib.mkDefault 4;
      nixPath = [
        "/nix"
        "nixos-config=/etc/nixos/configuration.nix"
      ];
      binaryCaches = [
        "https://cache.nixos.org/"
        "https://all-hies.cachix.org"
        "https://nixcache.reflex-frp.org"
        "https://hercules-ci.cachix.org"
      ];
      binaryCachePublicKeys = [
        "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
        "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
        "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
      ];
      trustedUsers = [ "root" "silvio" ];
    };

    fonts = {
      fonts = with pkgs; [
        source-code-pro
      ];
    };

    i18n = {
      consoleFont = "Lat2-Terminus16";
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
    };

    time.timeZone = "Europe/Zurich";

    environment.systemPackages = with pkgs; [
      cifs-utils
      emacs
      # lorri
      neovim
      # niv
      nmap
      samba
      silver-searcher
      wget
      speedtest-cli
      xorg.xrdb
      xrdp-vsock
      gitFull
    ];

    programs = {
      gnupg = {
        agent = {
          enable = true;
        };
      };
      iftop = {
        enable = true;
      };
      iotop = {
        enable = true;
      };
      mtr = {
        enable = true;
      };

      ssh = {
        startAgent = true;
        extraConfig = ''
        AddKeysToAgent yes
      '';
      };
    };

    services = {
      dbus.packages = [
        pkgs.gnome3.dconf
      ];

      openssh = {
        enable = true;
        permitRootLogin = "yes";
        forwardX11 = true;
      };

      samba = {
        enable = true;
        extraConfig = ''
        follow symlinks = yes
         '';
        # extraConfig = ''
        # workgroup = WORKGROUP
        # server string = "SURFACE-NIXOS"
        # netbios name = "SURFACE-NIXOS"
        #   guest account = nobody
        #   map to guest = bad user
        #   follow symlinks = yes
        # '';
        shares = {
          silvio = {
            comment = "Silvio's home";
            path = "/home/silvio";
            "valid users" = ["silvio"];
            public = "no";
            writable = "yes";
            browseable = "yes";
            printable = "no";
          };
        };
      };

      xrdp = {
        enable = true;
        package = pkgs.xrdp-vsock;
        defaultWindowManager = "/home/silvio/.xsession";
      };
    };

    networking = {
      enableIPv6 = true;
      defaultGateway = "172.21.21.1";
      nameservers = ["8.8.8.8" "192.168.2.1"];
      firewall = {
        allowedTCPPorts = [
          137 # netbios
          139 # netbios
          445 # smb
          3389 # Microsoft RDP
        ];
        allowedUDPPorts = [
          137 # netbios
          139 # netbios
        ];
      };
      interfaces = {
        eth0 = {
          ipv4 = {
            addresses = [{
              address = "172.21.21.2";
              prefixLength = 24;
            }];
          };
        };
      };
    };

    system.stateVersion = "20.03";

    users = {
      users =
        let
          sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR";
        in
          {
            silvio = {
              shell = pkgs.zsh;
              home = "/home/silvio";
              description = "Silvio Böhler";
              isNormalUser = true;
              extraGroups = [
                "audio"
                "cdrom"
                "docker"
                "libvirtd"
                "networkmanager"
                "transmission"
                "video"
                "wheel"
              ];
              uid = 1000;
              openssh.authorizedKeys.keys = [
                sshKey
                "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAswSg09K2gQuZ2g0pMTbn7dPhYJ+vjdstcCV12uEfi3eVDvn92g0NJDYyyNRPceG80FKJGJjTsTTk6Ocl0nZNyaELPwhHuG75By9KVdJYYibQ1f0mfTdU9OVSMyCMIpBohT9AAJMzqaNnvOzCQRpEQBmN3lToPDf/MleDoeVCtb4H2+hCIXcyBCe11DON3Wy5Ly+YdBEE0F5qSeN8Jk4vp//kSAFw3FOQiOMLMk+2z2HnW4G+BAN4YQ51qJ4R5m6lAqPA53Pw7EHvXNwpSWYsx0LKMCiFKekzNgv0gZ7kDlJYmRdkTkPCvZY4hy9QRlqyS3KHaVc7wh6v6uMARxufcw== NixOS"
              ];
            };
            root = {
              openssh.authorizedKeys.keys = [sshKey];
            };
          };
    };

    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };

    boot = {
      kernelParams = [ "elevator=noop" ];
      loader = {
        systemd-boot = {
          enable = true;
        };
        efi = {
          canTouchEfiVariables = true;
        };
      };
      initrd = {
        availableKernelModules = [ "sd_mod" "sr_mod" ];
      };
      kernelModules = ["hv_sock"];
      extraModulePackages = [ ];
    };

    virtualisation = {
      hypervGuest = {
        enable = true;
        videoMode = "1024x768";
      };
    };

    fileSystems."/home/silvio/winhome" = {
      device = "//172.21.21.1/silvio";
      fsType = "cifs";
      options = [
        "uid=1000"
        "gid=100"
        "credentials=/home/silvio/secrets/samba"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "x-systemd.automount"
      ];
    };
  };
}
