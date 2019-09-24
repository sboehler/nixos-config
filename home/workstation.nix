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
      options = ["ctrl:swapcaps" "compose:ralt" "terminate:ctrl_alt_bksp"];
    };

    home.sessionVariables = {
      TERMINAL = "${pkgs.gnome3.gnome-terminal}/bin/gnome-terminal";
    };

    programs.direnv = {
      enable = true;
    };

    services.pasystray.enable = true;

    services.redshift = {
      enable = true;
      provider = "geoclue2";
      tray = true;
    };

    services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      xssLockExtraOptions = ["-l"];
    };

    services.compton = {
      enable = true;
      fade = true;
      fadeSteps = ["0.08" "0.08"];
    };

    services.network-manager-applet.enable = true;

    services.blueman-applet.enable = true;

    services.dunst = {
      enable = true;
      iconTheme = {
        package = pkgs.gnome3.adwaita-icon-theme;
        name = "Adwaita";
      };
      settings = {
        global = {
          geometry = "500x5-40+40";
          font = "DejaVu Sans 8";
          markup = "full";
          format = "<b>%s</b>\n%b";
          icon_position = "left";
          transparency = 25;
          background = "#222222";
          foreground = "#888888";
          timeout = 3;
          padding = 16;
          frame_width = 0;
          frame_color = "#aaaaaa";
          word_wrap = true;
          stack_duplicates = true;
          show_indicators = false;
        };
        shortcuts = {
          close = "mod4+slash";
          close_all = "mod4+shift+slash";
          history = "mod4+grave";
          context = "mod4+shift+grave";
        };
        urgency_low = {
          background = "#222222";
          foreground = "#888888";
          timeout = 5;
        };
        urgency_normal = {
          background = "#285577";
          foreground = "#ffffff";
          timeout = 5;
        };
        urgency_critical = {
          background = "#900000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
        };
      };
    };

    services.udiskie = {
      enable = true;
      automount = true;
      tray = "always";
    };
  };
}
