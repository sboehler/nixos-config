{ pkgs, config, ...}
: {
  imports = [
    <home-manager/nixos>
  ];

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
      aliases = {
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        ls = "log --graph --decorate --pretty=format:\"%C(yellow)%h%C(red)%d %C(reset)%s %C(blue)[%cn]\"";
        cp = "cherry-pick";
        sh = "show --word-diff";
        st = "status -s";
        cl = "clone";
        ec = "commit -am \"empty\"";
        ci = "commit";
        co = "checkout";
        br = "branch";
        dc = "diff --cached";
        wd = "diff --word-diff";
        ll = "log --pretty=format:\"%h%C(reset)%C(red) %d %C(bold green)%s%C(reset)%Cblue [%cn] %C(green) %ad\" --decorate --numstat --date=iso";
        nc = "commit -a --allow-empty-message -m \"\"";
      };
    };

    home.sessionVariables = {
      EDITOR = "${pkgs.emacs}/bin/emacsclient -c";
      TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    };

    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          primary = {
            background = "0xffffff";
            foreground = "0x111111";
          };

          # Normal colors
          normal = {
            black=   "0x2e2e2e";
            red=     "0xeb4129";
            green=   "0xabe047";
            yellow=  "0xf6c744";
            blue=    "0x47a0f3";
            magenta= "0x7b5cb0";
            cyan=    "0x64dbed";
            white=   "0xe5e9f0";
          };

          # Bright colors
          bright = {
            black = "0x565656";
            red = "0xec5357";
            green =   "0xc0e17d";
            yellow =  "0xf9da6a";
            blue =    "0x49a4f8";
            magenta = "0xa47de9";
            cyan =    "0x99faf2";
            white =   "0xffffff";
          };
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
      shellAliases = {
        e = "emacsclient -c";
      };
      initExtra = ''
        export TERMINAL=${pkgs.alacritty}/bin/alacritty
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        # export GPG_TTY=$(tty)
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
      '';
    };
  };
}
