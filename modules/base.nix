{ config, pkgs, ... }:
  let
    unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/179b8146e668636fe59ef7663a6c8cd15d00db7e.tar.gz;
  in
{
  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
        };
      };
      allowUnfree = true;
    };
  };

  nix.buildCores = 0;
  nix.autoOptimiseStore = true;
  nix.nixPath = [
    "/nix"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  time.timeZone = "Europe/Zurich";

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
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
    exfat
    file
    git
    gnupg
    gptfdisk
    gopass
    hdparm
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
  ] ++ (with gitAndTools; [
    git-annex
    git-annex-remote-b2
    git-annex-remote-rclone
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
          "nvm"
          "rsync"
          "stack"
          "history-substring-search"
        ];
      };
      interactiveShellInit = ''
        export HUSKY_SKIP_INSTALL=true
        export EDITOR="emacsclient -c"
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        export GPG_TTY=$(tty)
        HYPHEN_INSENSITIVE="true"

        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down

        eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors.ansi-universal}")

        if [ $USER = "silvio" ]; then
          # systemctl --user import-environment
        fi
      '';

      shellAliases = {
        vim = "nvim";
      };
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        '';
    };
  };

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
  };

  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers = {
      silvio = {
        home = "/home/silvio";
        description = "Silvio Böhler";
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "libvirtd" "audio" "transmission"];
        uid = 1000;
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR"];
      };
      root = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqXLmL2FVGAkSlndgqaEDx0teA6Ai1wLu21KSdcBnV6XldetAHZ8AAeodgEqIYD/sO69xCm9Kwa3DbktdMO28MO6A7poQ4jvDVHray7mpsm3z5xgc1HAadjNUBvlPjPBbCvZkhcI2/MSvVknl5uFXeH58AqaIq6Ump4gIC27Mj9vLMuw7S5MoR6vJgxKK/h52yuKXs8bisBvrHYngBgxA0wpg/v3G04iplPtTtyIY3uqkgPv3VfMSEyOuZ+TLujFg36FxU5I7Ok0Bjf8f+/OdE41MYYUH1VPIHFtxNs8MPCcz2Sv0baxEhAiEBpnWsQx8mBhxmQ/cK4Ih2EOLqPKR silvio"];
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

}
