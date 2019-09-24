{ pkgs, config, lib, ...}
: {
  imports = [
    <home-manager/nixos>
    ./i3status-rust.nix
    ./xsession.nix
  ];

  home-manager.users.silvio = {
    home.keyboard = {
      layout = "us(altgr-intl)";
      model = "pc104";
      options = ["compose:ralt" "terminate:ctrl_alt_bksp"];
    };

    home.sessionVariables = {
      TERMINAL = "${pkgs.gnome3.gnome-terminal}/bin/gnome-terminal";
    };

    programs.direnv = {
      enable = true;
    };
  };
}
