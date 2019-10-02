{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
    ../home/base.nix
    ./users.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    buildCores = 0;
    autoOptimiseStore = true;
    nixPath = [
      "/nix"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_5_2;
    kernelParams = [ "usb-storage.quirks=152d:0578:u,0dc4:0210:u" ];
    extraModprobeConfig = ''
      options usb-storage quirks=152d:0578:u,0dc4:0210:u
    '';
  };

  hardware = {
    enableAllFirmware = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    ack
    bind
    borgbackup
    direnv
    exfat
    file
    gnupg
    gptfdisk
    gopass
    htop
    hdparm
    iotop
    jnettop
    gnumake
    ncftp
    nix-prefetch-scripts
    neovim
    nvme-cli
    (pass.withExtensions (e: [e.pass-otp]))
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
    # stable.haskellPackages.git-annex
  ] ++ (with gitAndTools; [
    git-annex
    git-annex-remote-b2
    git-annex-remote-rclone
    gitFull
  ]);

  virtualisation.docker.enable = true;

  time.timeZone = "Europe/Zurich";

  services.geoclue2.enable = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  programs.zsh.enable = true;

  services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    forwardX11 = true;
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
        AddKeysToAgent yes
      '';
  };



  services.fstrim.enable = true;

  services.timesyncd.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv6 = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
      hinfo = true;
      workstation = true;
    };
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  system.stateVersion = "19.09";
}
