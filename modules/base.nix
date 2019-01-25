{ config, pkgs, ... }:
let
  myEmacs = import ./emacs.nix { inherit pkgs; };
  # stable = import (pkgs.fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs-channels";
  #   rev = "9d608a6f592144b5ec0b486c90abb135a4b265eb";
  #   sha256 = "03brvnpqxiihif73agsjlwvy5dq0jkfi2jh4grp4rv5cdkal449k";
  # }) {};
in
{
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

  time.timeZone = "Europe/Zurich";

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_4_20;
  };

  hardware = {
    enableAllFirmware = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ack
    bind
    borgbackup
    direnv
    myEmacs
    exfat
    file
    gnupg
    gptfdisk
    gopass
    htop
    hdparm
    iotop
    jnettop
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

  programs = {

    gnupg = {
      agent = {
        enable = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        custom = "${./zsh-custom}";
        theme = "silvio";
        plugins = [
          "git"
          "gradle"
          "rsync"
          "stack"
          "history-substring-search"
        ];
      };
      interactiveShellInit = ''
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        export GPG_TTY=$(tty)
        HYPHEN_INSENSITIVE="true"

        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down

        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors.ansi-universal}")
        # systemctl --user import-environment PATH DISPLAY XAUTHORITY HOME GPG_TTY
      '';
    };

    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        '';
    };
  };

  services.emacs = {
    enable = true;
    defaultEditor = true;
    package = myEmacs;
  };

  systemd.user.services.emacs.environment.SSH_AUTH_SOCK = "%t/keyring/ssh";

  virtualisation.docker.enable = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
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

  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers = {
      silvio = {
        home = "/home/silvio";
        description = "Silvio Böhler";
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "libvirtd" "audio" "transmission" "networkmanager" "cdrom"];
        uid = 1000;
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR"];
      };
      root = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR silvio"];
      };
    };
  };

  security = {
    pam = {
      services.gdm.enableGnomeKeyring = true;
    };

    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  system.stateVersion = "19.03";
}
