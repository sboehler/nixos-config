{ pkgs, config, ... }:
let
  sources = import ../nix/sources.nix;
in
{
  imports = [
    <home-manager/nixos>
  ];

  nixpkgs.config = {

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

  nix = {
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

  # nix.useSandbox = true;

  documentation.dev.enable = true;

  hardware.brightnessctl.enable = true;

  powerManagement.enable = true;
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    ansible
    arandr
    # beancount
    brightnessctl
    chromium
    compton
    direnv
    docker_compose
    emacs
    evince
    firefox
    fdupes
    git-review
    gnome3.gnome-terminal
    hicolor-icon-theme
    gnome3.nautilus
    gnome3.gnome-screenshot
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gnumake
    imagemagick7
    ispell
    isync
    lorri
    macchanger
    manpages
    mu
    nix-index
    niv
    nodejs-10_x
    nodePackages.node2nix
    pandoc
    pinentry
    python3
    racket
    sbcl
    shared_mime_info
    stack
    (texlive.combine {
      inherit (texlive) scheme-medium moderncv cmbright wrapfig capt-of;
    })
    exiftool
    tabula
    # tor-browser-bundle-bin
    vanilla-dmz
    yarn
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
    # stylish-haskell
  ]);

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
    libinput = {
      enable = true;
      naturalScrolling = true;
      clickMethod = "clickfinger";
    };
  };

  services.emacs.install = true;

  services.dbus.packages = [
    pkgs.gnome3.dconf
  ];

  fonts = {
    enableDefaultFonts = false;
    fonts = with pkgs; [
      # nerdfonts
      carlito
      corefonts
      dejavu_fonts
      emojione
      font-awesome
      freefont_ttf
      google-fonts
      gyre-fonts # TrueType substitutes for standard PostScript fonts
      inconsolata
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
      noto-fonts-extra
      source-code-pro
      symbola
      xorg.fontbh100dpi
      xorg.fontbhlucidatypewriter100dpi
      xorg.fontbhlucidatypewriter75dpi
      xorg.fontcursormisc
      xorg.fontmiscmisc
    ];
  };
}
