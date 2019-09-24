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
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_4_19;
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

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
        AddKeysToAgent yes
      '';
  };

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
