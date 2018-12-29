{ pkgs, config, ... }:
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-10_x; };

      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: rec {
          beans = let
            tarball = builtins.fetchTarball "https://github.com/sboehler/beans/tarball/master";
          in haskellPackagesNew.callPackage (import tarball) {};
        };
      };

      gw = pkgs.callPackage ./gradlew.nix {};

      gradle = gradleGen.gradle_4_10;

      gradleGen = pkgs.gradleGen.override {
        jdk = pkgs.openjdk11;
      };

      hies = (import (builtins.fetchTarball {
        url = "https://github.com/domenkozar/hie-nix/tarball/master";
        sha256 = "0hilxgmh5aaxg37cbdwixwnnripvjqxbvi8cjzqrk7rpfafv352q";
      }) {}).hies;

      html2text = pkgs.html2text.overrideAttrs (oldAttrs: rec {
        patches = [
          ./html2text/100-fix-makefile.patch
          ./html2text/200-close-files-inside-main-loop.patch
          ./html2text/400-remove-builtin-http-support.patch
          ./html2text/500-utf8-support.patch
          ./html2text/510-disable-backspaces.patch
          ./html2text/550-skip-numbers-in-html-tag-attributes.patch
          ./html2text/600-multiple-meta-tags.patch
          ./html2text/611-recognize-input-encoding.patch
          ./html2text/630-recode-output-to-locale-charset.patch
          ./html2text/800-replace-zeroes-with-null.patch
          ./html2text/810-fix-deprecated-conversion-warnings.patch
          ./html2text/900-complete-utf8-entities-table.patch
          ./html2text/950-validate-width-parameter.patch
          ./html2text/960-fix-utf8-mode-quadratic-runtime.patch
        ];
      });
    };
  };

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://hie-nix.cachix.org"
    ];
    binaryCachePublicKeys = [
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
    ];
    trustedUsers = [ "root" "silvio" ];
  };

  # nix.useSandbox = true;

  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    jre = true;
  };

  programs.browserpass.enable = true;

  environment.systemPackages = with pkgs; [
    flashplayer
    ack
    ansible
    arandr
    beancount
    chromium
    darktable
    dmenu
    docker_compose
    evince
    firefox
    fdupes
    git-review
    gw
    gnome3.adwaita-icon-theme
    gnome3.eog
    gnome3.nautilus
    gradle
    gthumb
    hicolor-icon-theme
    hplip
    html2text
    i3lock
    icedtea8_web
    imagemagick7
    ispell
    isync
    jetbrains.datagrip
    jetbrains.idea-community
    keepassx2
    keepassxc
    libreoffice
    libressl
    libxml2
    macchanger
    mitscheme
    mu
    nix-index
    nodejs-10_x
    notmuch
    offlineimap
    openjdk11
    pavucontrol
    pandoc
    phantomjs
    python3
    restic
    rofi
    rubber
    sbcl
    shared_mime_info
    silver-searcher
    spotify
    termite
    texlive.combined.scheme-full
    thunderbird
    exiftool
    tabula
    taffybar
    tor-browser-bundle-bin
    vanilla-dmz
    virtmanager
    vlc
    wpa_supplicant
    wpa_supplicant_gui
    xautolock
    xiccd
    w3m
    xorg.xbacklight
    xorg.xcursorthemes
    xorg.xdpyinfo
    xorg.xev
    xorg.xkill
    xsel
    xss-lock
    yarn
    zbar
    zip
  ]

    ++ (with pkgs.haskellPackages; [
      beans
      cabal-install
      apply-refact
      cabal2nix
      # hasktags
      hindent
      # hlint
      hpack
      stylish-haskell
    ]);

  virtualisation.libvirtd.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.upower.enable = true;

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      sessionCommands = ''
        xset s 600 0
        xset r rate 440 50
        xss-lock -l -- i3lock -n &
        systemctl --user import-environment XDG_DATA_DIRS XDG_SESSION_PATH PATH HOME DISPLAY XAUTHORITY
        systemctl --user start wm.target
      '';
    };
    desktopManager = {
      xterm = {
        enable = false;
      };
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = false;
        extraPackages = haskellPackages: with haskellPackages; [
          hostname
          xmonad-contrib
          taffybar
        ];
      };
    };
  };

  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
  };

  networking.extraHosts = ''
    127.0.0.1	portal.test
    127.0.0.1	truewealth.test
    127.0.0.1 s3mock
  '';
  services.interception-tools.enable = true;
  services.redshift = {
    enable = true;
    provider = "manual";
    temperature = {
      night = 3400;
      day = 6500;
    };
    latitude = "47.3673";
    longitude = "8.55";
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      source-code-pro
      google-fonts
      liberation_ttf
      carlito
      inconsolata
    ];
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  services.colord = {
    enable = true;
  };

  systemd.user = {
    targets = {
      wm = {
        description = "Window Manager";
      };
    };
    services = {

      status-notifier-watcher = {
        description = "status-notifier-watcher";
        serviceConfig = {
          Type = "simple";
          ExecStart="${pkgs.haskellPackages.status-notifier-item}/bin/status-notifier-watcher";
          ExecStop="${pkgs.procps}/bin/pkill status-notifier-watcher";
        };
        wantedBy = ["wm.target"];
      };

      taffybar = {
        description = "taffybar";
        unitConfig = {
          Requires = "status-notifier-watcher.service";
          After = "status-notifier-watcher.service";
        };
        serviceConfig = {
          Type = "notify";
          ExecStart="${pkgs.taffybar}/bin/taffybar";
          ExecStop="${pkgs.procps}/bin/pkill taffybar";
        };
        environment = {
          GDK_SCALE = "1";
          GDK_DPI_SCALE = "1";
        };
        wantedBy = ["wm.target"];
      };

      wpa_gui = {
        description = "wpa gui";
        unitConfig = {
          Requires = "taffybar.service";
          After = "taffybar.service";
        };
        path = [ "/run/current-system/sw" ];
        serviceConfig = {
          Type = "simple";
          ExecStart="${pkgs.wpa_supplicant_gui}/bin/wpa_gui -t";
          ExecStop="${pkgs.procps}/bin/pkill wpa_gui";
        };
        wantedBy = ["wm.target"];
      };
    };
  };
}
