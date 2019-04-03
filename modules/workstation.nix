{ pkgs, config, ... }:
let
  myEmacs = import ./emacs.nix { inherit pkgs; };
in
{
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-10_x; };

      rofi-launcher = pkgs.callPackage ./rofi {};

      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc864 = pkgs.haskell.packages.ghc864.override {
            overrides = self: super: {
              beans = self.callPackage ./beans.nix {};
              dhall = self.callPackage ./dhall.nix {};
              dhall-json = self.callPackage ./dhall-json.nix {};
            };
          };
        };
      };
      haskellPackages = haskell.packages.ghc864;

      gw = pkgs.callPackage ./gradlew.nix {};

      gradleGen = pkgs.gradleGen.override {
        jdk = pkgs.openjdk11;
      };

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

  environment.systemPackages = with pkgs; [
    adwaita-qt
    ansible
    beancount
    chromium
    darktable
    digikam
    dhall
    dhall-json
    direnv
    docker_compose
    myEmacs
    evince
    # firefox
    (if config.services.xserver.displayManager.gdm.wayland
      then firefox-wayland
      else firefox)
    fdupes
    git-review
    gw
    gradle
    gthumb
    gnome-podcasts
    gnome3.polari
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gnome3.geary
    hplip
    html2text
    icedtea8_web
    imagemagick7
    ispell
    isync
    jetbrains.datagrip
    jetbrains.idea-community
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
    openjdk11
    pavucontrol
    pandoc
    pinentry_gnome
    python3
    # qt5.full
    # libsForQt5.qtstyleplugins
    # libsForQt5.libkipi
    rofi
    rofi-launcher
    rubber
    sbcl
    shared_mime_info
    spotify
    termite
    (texlive.combine {
      inherit (texlive) scheme-medium moderncv cmbright;
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
    zip
  ]
  ++ (with pkgs.gnomeExtensions; [
    system-monitor
    caffeine
    no-title-bar
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
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  services.emacs = {
    install = true;
    enable = true;
    defaultEditor = true;
    package = myEmacs;
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
