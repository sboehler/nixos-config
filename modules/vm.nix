{ config, pkgs, lib, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports =
    [
      <home-manager/nixos>
    ];

  nixpkgs = {
    config = {
      allowUnfree = true;

      packageOverrides = pkgs: rec {
        niv = (import sources.niv {}).niv;
        lorri = (import sources.lorri {});

        haskell = pkgs.haskell // {
          packages = pkgs.haskell.packages // {
            ghc865 = pkgs.haskell.packages.ghc865.override {
              overrides = self: super: {
                beans = self.callPackage ./beans.nix {};
              };
            };
          };
        };

        haskellPackages = haskell.packages.ghc865;
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
    enableDefaultFonts = false;
    fonts = with pkgs; [
      carlito
      corefonts
      emojione
      font-awesome
      google-fonts
      inconsolata
      nerdfonts
      noto-fonts
      noto-fonts-extra
      source-code-pro
      symbola

      # default fonts (except unifont)
      xorg.fontbhlucidatypewriter100dpi
      xorg.fontbhlucidatypewriter75dpi
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf
      xorg.fontbh100dpi
      xorg.fontmiscmisc
      xorg.fontcursormisc
      noto-fonts-emoji
    ];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Zurich";

  environment.systemPackages = with pkgs; [
    emacs
    lorri
    neovim
    niv
    nmap
    samba
    silver-searcher
    wget
    xorg.xrdb
  ] ++ (with gitAndTools; [
    git-annex
    git-annex-remote-b2
    git-annex-remote-rclone
    gitFull
  ]);

  programs = {
    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
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
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
      forwardX11 = true;
    };

    samba = {
      enable = true;
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
          path = "/home/silvio/shared";
          "valid users" = ["silvio"];
          public = "no";
          writable = "yes";
          browseable = "yes";
          printable = "no";
        };
      };
    };
  };

  networking = {
    enableIPv6 = true;
    defaultGateway = "192.168.4.1";
    nameservers = ["8.8.8.8" "192.168.4.1"];
    firewall = {
      allowedTCPPorts = [
        137 # netbios
        139 # netbios
        445 # smb
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
            address = "192.168.4.2";
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
            openssh.authorizedKeys.keys = [sshKey];
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
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  virtualisation = {
    hypervGuest = {
      enable = true;
      videoMode = "1024x768";
    };
  };

  home-manager = {
    users = {
      silvio = {
        services = {
          gpg-agent = {
            enable = true;
          };
        };

        programs = {
          direnv = {
            enable = true;
          };

          zsh = {
            enable = true;
            enableCompletion = true;
            initExtra = ''
              HYPHEN_INSENSITIVE="true"
            '';
          };

          git = {
            enable = true;
            userName  = "Silvio Böhler";
            userEmail = "sboehler@noreply.users.github.com";
            extraConfig = {
              merge.conflictstyle = "diff3";
              pull.rebase = true;
              rebase = {
                autosquash = true;
                autostash = true;
              };
              color.ui = true;
            };
            aliases = {
              unstage = "reset HEAD --";
              last = "log -1 HEAD";
              ls = ''log --graph --decorate --pretty=format:\"%C(yellow)%h%C(red)%d %C(reset)%s %C(blue)[%cn]\"'';
              cp = "cherry-pick";
              sh = "show --word-diff";
              ci = "commit";
              dc = "diff --cached";
              wd = "diff --word-diff";
              ll = ''log --pretty=format:\"%h%C(reset)%C(red) %d %C(bold green)%s%C(reset)%Cblue [%cn] %C(green) %ad\" --decorate --numstat --date=iso'';
              nc = ''commit -a --allow-empty-message -m \"\"'';
              cr = ''commit -C HEAD@{1}'';
            };
          };
        };
      };
    };
  };
}
