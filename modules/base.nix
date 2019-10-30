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
  };

  hardware = {
    enableRedistributableFirmware = true;
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


  time.timeZone = "Europe/Zurich";


  services.btrfs = {
    autoScrub = {
      enable = true;
#      fileSystems = [ "/" ];
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


  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  system.stateVersion = "19.09";
}
