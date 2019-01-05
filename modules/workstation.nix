{ pkgs, config, ... }:
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-10_x; };

      rofi-launcher = pkgs.callPackage ./rofi {};

      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc863 = pkgs.haskell.packages.ghc863.override {
            overrides = self: super: {
              beans = let
                tarball = builtins.fetchTarball "https://github.com/sboehler/beans/tarball/master";
              in self.callPackage (import tarball) {};
            };
          };
        };
      };
      haskellPackages = haskell.packages.ghc863;

      gw = pkgs.callPackage ./gradlew.nix {};

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
    gradle
    gthumb
    gnome3.rhythmbox
    gnome3.gnome-boxes
    hplip
    html2text
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
    pinentry_gnome
    python3
    qt5.full
    rofi
    rofi-launcher
    rubber
    sbcl
    shared_mime_info
    spotify
    termite
    texlive.combined.scheme-full
    thunderbird
    exiftool
    tabula
    tor-browser-bundle-bin
    vanilla-dmz
    virtmanager
    vlc
    xautolock
    xiccd
    w3m
    xsel
    yarn
    zbar
    zip
  ]
  ++ (with pkgs.gnomeExtensions; [
    system-monitor
    caffeine
    no-title-bar
    dash-to-panel
  ])

    ++ (with pkgs.haskellPackages; [
      # beans
      cabal-install
      apply-refact
      cabal2nix
      # hasktags
      hindent
      # hlint
      hpack
      # stylish-haskell
    ]);

  virtualisation.libvirtd.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  boot.plymouth.enable = true;

  powerManagement.enable = true;

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      gdm = {
        enable = true;
        # autoLogin = {
        #   enable = true;
        #   user = "silvio";
        # };
      };
    };
    desktopManager = {
      gnome3 = {
        enable = true;
      };
      xterm = {
        enable = false;
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
}
