{ pkgs, config, ... }:
let
  unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
    ack
    chromium
    darktable
    dmenu
    evince
    exiftool
    firefox
    gnome3.eog
    gnome3.nautilus
    gthumb
    haskellPackages.xmobar
    i3lock
    icedtea8_web
    imagemagick7
    ispell
    isync
    libreoffice
    mu
    nix-repl
    nix-repl
    pavucontrol
    shared_mime_info
    silver-searcher
    termite
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
    xsel
    xss-lock
  ]

  ++ (with unstable; [
    docker_compose
    emacs
    gradle
    jetbrains.datagrip
    jetbrains.idea-community
    nodejs-8_x
    mitscheme
    skypeforlinux
    openjdk
    yarn
  ])

  ++ (with pkgs.haskellPackages; [
    cabal-install
    apply-refact
    cabal2nix
    ghc
    hasktags
    hindent
    hlint
    hpack
    hoogle
    #stylish-haskell
  ]);

  virtualisation.libvirtd.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "ctrl:nocaps,compose:ralt,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      lightdm = {
        enable = true;
      };
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
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [
          haskellPackages.hostname
        ];
      };
    };
  };

  networking.extraHosts = ''
    127.0.0.1	portal.test
    127.0.0.1	truewealth.test
  '';

  services.redshift = {
    enable = true;
    provider = "geoclue2";
    extraOptions = ["-v"];
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
}
