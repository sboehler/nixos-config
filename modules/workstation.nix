{ pkgs, config, ... }:
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-8_x; };

      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: rec {
          beans = haskellPackagesNew.callPackage ./beans.nix {};
          xmonad = haskellPackagesNew.callPackage ./xmonad.nix {};
          xmonad-contrib = haskellPackagesNew.callPackage ./xmonad-contrib.nix {};
        };
      };

      gw = pkgs.callPackage ./gradlew.nix {};

      gradle = gradleGen.gradle_latest;

      gradleGen = pkgs.gradleGen.override {
        jdk = pkgs.openjdk10;
      };

    };
  };

  environment.systemPackages = with pkgs; [
    # flashplayer
    # skypeforlinux
    ack
    ansible
    arandr
    beancount
    chromium
    darktable
    dmenu
    docker_compose
    emacs
    evince
    firefox
    fdupes
    git-review
    gw
    # flashplayer
    gnome3.eog
    gnome3.nautilus
    gradle
    gthumb
    hplip
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
    mitscheme
    mu
    nix-index
    nodejs-8_x
    notmuch
    offlineimap
    openjdk10
    pavucontrol
    pandoc
    phantomjs
    python3
    protonmail-bridge
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
    vanilla-dmz
    virtmanager
    virtmanager
    vlc
    wpa_supplicant
    xautolock
    xiccd
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
    # beans
    cabal-install
    apply-refact
    cabal2nix
    # hasktags
    hindent
    # hlint
    hpack
    stylish-haskell
    xmobar

  ]);

  virtualisation.libvirtd.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "ctrl:nocaps,compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      sessionCommands = ''
          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -n &
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
        extraPackages = haskellPackages: [
          haskellPackages.hostname
          haskellPackages.xmonad-contrib
        ];
      };
    };
  };

  networking.extraHosts = ''
    127.0.0.1	portal.test
    127.0.0.1	truewealth.test
    127.0.0.1 s3mock
  '';

  services.redshift = {
    enable = true;
    provider = "manual";
    latitude = "47.3673";
    longitude = "8.55";
  };

  services.emacs.enable = true;

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
