{ pkgs, config, ... }:
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-10_x; };

      rofi-launcher = pkgs.callPackage ./rofi {};

      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc865 = pkgs.haskell.packages.ghc865.override {
            overrides = self: super: {
              beans = self.callPackage ./beans.nix {};
              # dhall = self.callPackage ./dhall.nix {};
              # dhall-json = self.callPackage ./dhall-json.nix {};
            };
          };
        };
      };
      haskellPackages = haskell.packages.ghc865;

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

  services.logind.extraConfig = ''
    HandlePowerKey="suspend"
  '';

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://hie-nix.cachix.org"
      "https://nixcache.reflex-frp.org"
    ];
    binaryCachePublicKeys = [
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    ];
    trustedUsers = [ "root" "silvio" ];
  };

  # nix.useSandbox = true;

  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
    jre = true;
  };

  documentation.dev.enable = true;

  programs.browserpass.enable = true;
  hardware.brightnessctl.enable = true;


  environment.systemPackages = with pkgs; [
    adwaita-qt
    ansible
    beancount
    brightnessctl
    chromium
    compton
    darktable
    digikam
    dhall
    dhall-json
    direnv
    docker_compose
    dunst
    emacs
    evince
    firefox
    # (if config.services.xserver.displayManager.gdm.wayland
    #   then firefox-wayland
    #   else firefox)
    fdupes
    git-review
    gradle
    gthumb
    # gnome-podcasts
    gnome3.polari
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gnome3.geary
    gnumake
    hplip
    html2text
    icedtea8_web
    imagemagick7
    ispell
    isync
    jetbrains.idea-ultimate
    libreoffice
    libressl
    libxml2
    macchanger
    manpages
    meld
    mu
    nix-index
    nodejs-10_x
    nodePackages.node2nix
    pavucontrol
    pandoc
    pinentry_emacs
    python3
    # qt5.full
    # libsForQt5.qtstyleplugins
    # libsForQt5.libkipi
    racket
    rofi
    rofi-launcher
    rubber
    sbcl
    shared_mime_info
    spotify
    stack
    termite
    tilix
    (texlive.combine {
      inherit (texlive) scheme-medium moderncv cmbright wrapfig capt-of;
    })
    thunderbird
    exiftool
    tabula
    # tor-browser-bundle-bin
    vanilla-dmz
    vlc
    xiccd
    w3m
    yarn
    xss-lock
    zip
  ]
  ++ (with pkgs.gnomeExtensions; [
    # system-monitor
    caffeine
    # no-title-bar
    dash-to-panel
  ])

    ++ (with pkgs.haskellPackages; [
      beans
      cabal-install
      apply-refact
      cabal2nix
      # hasktags
      hindent
      # hlint
      hpack
      # stylish-haskell
    ]);

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  powerManagement.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.gnome3.enable = true;
    desktopManager.xterm.enable = false;

    layout = "us(altgr-intl)";
    xkbModel = "pc104";
    xkbOptions = "ctrl:swapcaps,compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      gdm.enable = true;
      sessionCommands = ''
        xset s 600 0
        xset r rate 440 50
      '';
    };
    windowManager.i3 = {
      extraSessionCommands = ''
        export GDK_SCALE=2
        export GDK_DPI_SCALE=0.5
        systemctl --user import-environment DISPLAY
        systemctl --user restart emacs.service &
        ${pkgs.xorg.xrandr}/bin/xrandr --dpi 200 --output eDP-1
      '';
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        dmenu
        rofi
        networkmanagerapplet
        blueman
        i3status
        i3lock ];
    };
  };

  services.emacs = {
    install = true;
    enable = true;
    defaultEditor = true;
  };

  systemd.user.services.emacs.environment.SSH_AUTH_SOCK = "%t/keyring/ssh";

  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
  };

  networking.extraHosts = ''
    127.0.0.1	portal.truewealth.test
    127.0.0.1	truewealth.test
    127.0.0.1 s3mock
  '';

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
