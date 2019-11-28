{ config, pkgs, lib, ... }:

{
  imports = [
    <home-manager/nixos>
    ./users.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    buildCores = 0;
    maxJobs = lib.mkDefault 4;
    autoOptimiseStore = true;
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

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_5_3;
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # lorri
    # niv
    ack
    bind
    cifs-utils
    cryptsetup
    direnv
    emacs
    exfat
    file
    git-crypt
    gitFull
    gnumake
    gnupg
    gptfdisk
    hdparm
    htop
    iotop
    jnettop
    ncftp
    neovim
    nix-prefetch-scripts
    nmap
    nvme-cli
    patchelf
    pciutils
    pinentry
    powertop
    psmisc
    python
    rclone
    restic
    samba
    silver-searcher
    smartmontools
    speedtest-cli
    stow
    sysstat
    termite.terminfo
    tmux
    tree
    unzip
    upower
    wget
    xorg.xrdb
    wget
  ];

  time.timeZone = "Europe/Zurich";

  services= {
    btrfs = {
      autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
      };
    };

    fwupd.enable = true;

    fstrim.enable = true;

    timesyncd.enable = true;

    openssh = {
      enable = true;
      passwordAuthentication = false;
      forwardX11 = true;
      permitRootLogin = "no";
      openFirewall = false;
    };
  };

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      histSize = 100000;
      promptInit = ''
        autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
        '';
      setOptions =  [
        "hist_ignore_dups"
        "share_history"
        "hist_fcntl_lock"
        "auto_cd"
        "extended_glob"
      ];
    };

    gnupg.agent.enable = true;

    iftop.enable = true;

    iotop.enable = true;

    mtr.enable = true;
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  system.stateVersion = "20.03";
}
