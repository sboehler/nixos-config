{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.emacs = {
    enable = true;
  };

  home.packages = [
    pkgs.htop
    pkgs.fortune
    pkgs.source-code-pro
    pkgs.silver-searcher
    pkgs.pinentry
  ];

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
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

  programs.direnv.enable = true;

  xresources.properties = {
    "Xft.dpi" = 144;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "history-substring-search"
      ];
    };
    initExtra = ''
        HYPHEN_INSENSITIVE="true"
        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down
      '';
  };

  services.gpg-agent = {
    enable = true;
    extraConfig = ''
      pinentry-program ${pkgs.pinentry}/bin/pinentry
    '';
  };
}
