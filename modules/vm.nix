{ config, pkgs, lib, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports =
    [
      <home-manager/nixos>
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
      cifs-utils
      emacs
      # lorri
      neovim
      niv
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
      device = "//${config.hostHostName}/silvio";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,uid=1000,gid=100,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/home/silvio/secrets/samba"];
    };

    # systemd.mounts = [
    #   {
    #     type = "cifs";
    #     where = "/home/silvio/winhome";
    #     what= "//192.168.4.1/silvio";
    #     options= "credentials=/home/silvio/secrets/samba,uid=1000,gid=100,rw";
    #     unitConfig = {
    #       after = "network-online.service";
    #       requires = "network-online.target";
    #       wantedBy = "multi-user.target";
    #     };
    #   }
    # ];

    home-manager = {
      users = {
        silvio = {

          systemd = {
            user = {
              sessionVariables = {
                EDITOR = "${pkgs.emacs}/bin/emacs";
              };
            };
          };

          gtk = {
            enable = true;
            theme = {
              package = pkgs.gnome3.gnome-themes-standard;
              name = "Adwaita";
            };
            font = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans 10";
            };
            iconTheme = {
              package = pkgs.gnome3.adwaita-icon-theme;
              name = "Adwaita";
            };
          };

          home = {
            sessionVariables = {
              TERMINAL = "${pkgs.gnome3.gnome-terminal}/bin/gnome-terminal";
              EDITOR = "${pkgs.emacs}/bin/emacs";
            };
          };

          services = {
            gpg-agent = {
              enable = true;
            };
          };

          programs = {

            bash = {
              enable = true;
            };

            direnv = {
              enable = true;
            };

            gnome-terminal = {
              enable = true;
              showMenubar = false;
              profile = {
                profile = {
                  default = true;
                  visibleName = "silvio";
                  font = "Source Code Pro";
                  allowBold = true;
                };
              };
            };

            zsh = {
              enable = true;
              enableCompletion = true;
              initExtra = ''
              HYPHEN_INSENSITIVE="true"
              [ ! -z "$DISPLAY" ] && xrdb -merge ~/.Xresources
              alias ls='ls --color=auto'
              alias ll='ls -la'
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

            tmux = {
              enable = true;
              baseIndex = 1;
              clock24 = true;
              disableConfirmationPrompt = true;
            };
          };

          xsession = {
            enable = true;
            windowManager = {
              i3 = {
                enable = true;
                config = let
                  modifier = "Mod4";
                in {
                  inherit modifier;
                  fonts = ["DejaVu Sans Mono" "FontAwesome5Free 10"];
                  keybindings = lib.mkOptionDefault {
                    "${modifier}+d" = ''exec --no-startup-id "${pkgs.rofi}/bin/rofi -combi-modi window,drun -show combi -modi combi,run"'';

                    "${modifier}+Control+j" = "focus left";
                    "${modifier}+Control+k" = "focus down";
                    "${modifier}+Control+l" = "focus up";
                    "${modifier}+Control+semicolon" = "focus right";

                    "${modifier}+Shift+j" = "move left 40px";
                    "${modifier}+Shift+k" = "move down 40px";
                    "${modifier}+Shift+l" = "move up 40px";
                    "${modifier}+Shift+semicolon" = "move right 40px";

                    "${modifier}+a" = "focus parent";
                    "${modifier}+q" = "focus child";

                    "${modifier}+Shift+e" = "exit";
                    "${modifier}+apostrophe" = "mode app";
                  };

                  modes = lib.mkOptionDefault {
                    resize = {
                      "j" = "resize shrink width 10 px or 10 ppt";
                      "k" = "resize grow height 10 px or 10 ppt";
                      "l" = "resize shrink height 10 px or 10 ppt";
                      "semicolon" = "resize grow width 10 px or 10 ppt";
                      "${modifier}+r" = "mode default";
                    };
                    app = {
                      "f" = "exec ${pkgs.firefox}/bin/firefox; mode default";
                      "e" = "exec ${pkgs.emacs}/bin/emacsclient -c; mode default";
                      "${modifier}+apostrophe" = "mode default";
                      "Escape" = "mode default";
                      "Return" = "mode default";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
