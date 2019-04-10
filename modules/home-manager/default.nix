{ pkgs, config, ...}
: {
  imports = [
    <home-manager/nixos>
  ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  home-manager.users.silvio = {
    programs.git = {
      enable = true;
      userName  = "Silvio Böhler";
      userEmail = (if config.networking.hostName == "worky-mcworkface"
        then "silvio.boehler@truewealth.ch"
        else "sboehler@noreply.users.github.com");
      extraConfig = {
        merge = {
          conflictstyle = "diff3";
        };
      };
    };

    home.packages = [
      pkgs.fortune
    ];

    dconf = {
      enable = true;
      settings = {

        "org/gnome/mutter/keybindings" = {
          toggle-tiled-right = ["<Super>i"];
          toggle-tiled-left = ["<Super>u"];
        };

        "org/gnome/desktop/wm/keybindings" = {
          always-on-top = ["<Super>t"];
          cycle-windows = ["<Super>j"];
          cycle-windows-backward = ["<Super>k"];

          maximize-vertically = ["<Super><Shift>semicolon"];
          toggle-maximized = ["<Super>semicolon"];
          minimize = [""];
          maximize = [""];
          unmaximize = [""];

          switch-to-workspace-up = ["<Super>l"];
          switch-to-workspace-down = ["<Super>h"];
          move-to-workspace-up = ["<Super><Shift>l"];
          move-to-workspace-down = ["<Super><Shift>h"];
          move-to-monitor-right = ["<Super><Shift>k"];
          move-to-monitor-left = ["<Super><Shift>j"];

          move-to-center = ["<Control><Super>semicolon"];
          move-to-side-e = ["<Control><Super>l"];
          move-to-side-s = ["<Control><Super>j"];
          move-to-side-w = ["<Control><Super>h"];
          move-to-side-n = ["<Control><Super>k"];

          toggle-fullscreen = ["<Super>f"];
        };

        "org/gnome/terminal/legacy/keybindings" = {
          prev-tab = "<Super>comma";
          next-tab = "<Super>period";
          move-tab-left = "<Super>less";
          move-tab-right = "<Super>greater";
          toggle-menubar = "F12";
        };
      };
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      oh-my-zsh = {
        enable = true;
        custom = "${./zsh-custom}";
        theme = "silvio";
        plugins = [
          "git"
          "rsync"
          "stack"
          "history-substring-search"
        ];
      };
      initExtra = ''
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        export GPG_TTY=$(tty)
        HYPHEN_INSENSITIVE="true"

        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down

        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors.ansi-universal}")
      '';
    };
  };
}
