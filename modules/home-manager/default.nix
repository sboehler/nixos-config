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

        "org/gnome/shell/keybindings" = {
          switch-to-application-1 = "[]";
          switch-to-application-2 = "[]";
          switch-to-application-3 = "[]";
          switch-to-application-4 = "[]";
          switch-to-application-5 = "[]";
          switch-to-application-6 = "[]";
          switch-to-application-7 = "[]";
          switch-to-application-8 = "[]";
          switch-to-application-9 = "[]";
        };

        "org/gnome/desktop/wm/keybindings" = {
          always-on-top = ["<Super>t"];
          cycle-windows = ["<Super>j"];
          cycle-windows-backward = ["<Super>k"];
          # switch-windows = ["<Super>k"];
          # switch-windows-backward = ["<Super>j"];
          switch-applications = ["<Super>period"];
          switch-applications-backward = ["<Super>comma"];
          cycle-group = ["<Super><Shift>period"];
          cycle-group-backward = ["<Super><Shift>comma"];

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
          move-to-workspace-1 = ["<Super><Shift>1"];
          move-to-workspace-2 = ["<Super><Shift>2"];
          move-to-workspace-3 = ["<Super><Shift>3"];
          move-to-workspace-4 = ["<Super><Shift>4"];
          move-to-workspace-5 = ["<Super><Shift>5"];
          move-to-workspace-6 = ["<Super><Shift>6"];
          move-to-workspace-7 = ["<Super><Shift>7"];
          move-to-workspace-8 = ["<Super><Shift>8"];
          move-to-workspace-9 = ["<Super><Shift>9"];

          go-to-workspace-1 = ["<Super>1"];
          go-to-workspace-2 = ["<Super>2"];
          go-to-workspace-3 = ["<Super>3"];
          go-to-workspace-4 = ["<Super>4"];
          go-to-workspace-5 = ["<Super>5"];
          go-to-workspace-6 = ["<Super>6"];
          go-to-workspace-7 = ["<Super>7"];
          go-to-workspace-8 = ["<Super>8"];
          go-to-workspace-9 = ["<Super>9"];

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

        # Fix tramp:

        if [[ "$TERM" == "dumb" ]]
        then
          unsetopt zle
          unsetopt prompt_cr
          unsetopt prompt_subst
          unfunction precmd
          unfunction preexec
          PS1='$ '
        fi

        if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
          source ${pkgs.vte}/etc/profile.d/vte.sh
        fi
      '';
    };
  };
}
