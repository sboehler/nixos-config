{ config, pkgs, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports =
    [
      <home-manager/nixos>
      ./base.nix
      ./home/base.nix
      ./home/xorg.nix
    ];

  config = {
    nixpkgs = {
      config = {
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

    fonts = {
      fonts = with pkgs; [
        source-code-pro
      ];
    };

    environment.systemPackages = with pkgs; [
      xrdp-vsock
    ];

    services = {
      dbus.packages = [
        pkgs.gnome3.dconf
      ];

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

    users.users = let
      sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR";
    in {
      silvio.openssh.authorizedKeys.keys = [ sshKey ];
      root.openssh.authorizedKeys.keys = [sshKey];
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
