{ pkgs, config, ... }:
{
  nixpkgs.config = {
    packageOverrides = pkgs: {
      yarn = pkgs.yarn.override { nodejs = pkgs.nodejs-8_x;  };
    };
  };

  environment.systemPackages = with pkgs; [
    ack
    arandr
    chromium
    darktable
    dmenu
    docker_compose
    emacs
    evince
    exiftool
    firefox
    # flashplayer
    gnome3.eog
    gnome3.nautilus
    gradle
    gthumb
    haskellPackages.xmobar
    hplip
    i3lock
    icedtea8_web
    imagemagick7
    ispell
    isync
    jetbrains.datagrip
    jetbrains.idea-community
    keepassx2
    libreoffice
    libxml2
    mitscheme
    libreoffice
    mu
    nix-repl
    nodejs-8_x
    notmuch
    openjdk10
    pavucontrol
    python36Packages.html2text
    rofi
    rubber
    shared_mime_info
    silver-searcher
    # skypeforlinux
    termite
    texlive.combined.scheme-full
    vanilla-dmz
    virtmanager
    virtmanager
    vlc
    wpa_supplicant
    xautolock
    xiccd
    xorg.xbacklight
    xorg.xkill
    xorg.xcursorthemes
    xorg.xdpyinfo
    xorg.xev
    xsel
    xss-lock
    yarn
    zbar
    zip
  ]

  ++ (with pkgs.haskellPackages; [
    cabal-install
    apply-refact
    cabal2nix
    ghc
    ghcid
    # hasktags
    hindent
    hlint
    hpack
    hoogle
    stylish-haskell
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
