{ pkgs, config, lib, ...}
: {
  imports = [
    <home-manager/nixos>
    ./i3status-rust.nix
  ];

  home-manager.users.silvio = {

    programs.git = {
      enable = true;
      userName  = "Silvio Böhler";
      userEmail = (if config.networking.hostName == "worky-mcworkface"
        then "silvio.boehler@truewealth.ch"
        else "sboehler@noreply.users.github.com");
      extraConfig = {
        merge.conflictstyle = "diff3";
        pull.rebase = true;
        rebase.autosquash = true;
        rebase.autostash = true;
        color.ui = true;
      };
      aliases = {
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        ls = ''log --graph --decorate --pretty=format:\"%C(yellow)%h%C(red)%d %C(reset)%s %C(blue)[%cn]\"'';
        cp = "cherry-pick";
        sh = "show --word-diff";
        ci = "commit";
        dc = "diff --cached";
        wd = "diff --word-diff";
        ll = ''log --pretty=format:\"%h%C(reset)%C(red) %d %C(bold green)%s%C(reset)%Cblue [%cn] %C(green) %ad\" --decorate --numstat --date=iso'';
        nc = ''commit -a --allow-empty-message -m \"\"'';
        cr = ''commit -C HEAD@{1}'';
      };
    };

    home.sessionVariables = {
      EDITOR = "${pkgs.emacs}/bin/emacsclient -c";
    };

    services.emacs.enable = true;

    programs.emacs.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtlSsh = 3600;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      oh-my-zsh = {
        enable = true;
        theme = "avit";
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
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        HYPHEN_INSENSITIVE="true"

        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down

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
