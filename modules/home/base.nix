{ pkgs, ...}
: {
  home-manager.users.silvio = {

    programs = {

      git = {
        enable = true;
        userName  = "Silvio Böhler";
        userEmail = "sboehler@noreply.users.github.com";
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

      tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        disableConfirmationPrompt = true;
        shortcut = "a";
        newSession = true;
        extraConfig = ''
          bind C-a send-prefix
          set -g mouse on
        '';
      };

      emacs.enable = true;

      direnv.enable = true;

      bash.enable = true;

      zsh = {
        enable = false;
        enableCompletion = true;
        shellAliases = {
          e = "emacsclient -c";
        };
        initExtra = ''
        export PATH=$HOME/.local/bin:$PATH
        HYPHEN_INSENSITIVE="true"

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

    services = {
      emacs.enable = true;
      gpg-agent.enable = true;
    };

    home.sessionVariables = {
      EDITOR = "${pkgs.emacs}/bin/emacsclient -c";
    };
  };
}
