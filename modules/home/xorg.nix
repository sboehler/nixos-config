{ pkgs, config, lib, ...}:
{
  home-manager.users.silvio = {

    home = {
      keyboard = {
        layout = "us(altgr-intl)";
        model = "pc104";
        options = ["ctrl:swapcaps" "compose:ralt" "terminate:ctrl_alt_bksp"];
      };
      sessionVariables = {
        TERMINAL = "${pkgs.gnome3.gnome-terminal}/bin/gnome-terminal";
      };
    };
    programs = {
      gnome-terminal = {
        enable = true;
        showMenubar = false;
        profile = {
          profile = {
            default = true;
            visibleName = "silvio";
            font = "Source Code Pro";
            allowBold = true;
          };
        };
      };
    };

    xsession = {
      enable = true;
      initExtra = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge $HOME/.Xresources
      '';
      windowManager = {
        i3 = let
          mod = "Mod4";
        in {
          enable = true;
          config = {
            modifier = mod;
            fonts = ["DejaVu Sans Mono" "FontAwesome5Free 10"];
            keybindings = lib.mkOptionDefault {
              "${mod}+d" = ''exec --no-startup-id "${pkgs.rofi}/bin/rofi -combi-modi window,drun -show combi -modi combi,run"'';

              "${mod}+j" = "focus left";
              "${mod}+k" = "focus down";
              "${mod}+l" = "focus up";
              "${mod}+semicolon" = "focus right";

              "${mod}+Shift+j" = "move left 40px";
              "${mod}+Shift+k" = "move down 40px";
              "${mod}+Shift+l" = "move up 40px";
              "${mod}+Shift+semicolon" = "move right 40px";

              "${mod}+a" = "focus parent";
              "${mod}+q" = "focus child";

              "${mod}+Shift+e" = "exit";
              "${mod}+apostrophe" = "mode app";
            };

            modes = lib.mkOptionDefault {
              resize = {
                "j" = "resize shrink width 10 px or 10 ppt";
                "k" = "resize grow height 10 px or 10 ppt";
                "l" = "resize shrink height 10 px or 10 ppt";
                "semicolon" = "resize grow width 10 px or 10 ppt";
                "${mod}+r" = "mode default";
              };
              app = {
                "f" = "exec ${pkgs.firefox}/bin/firefox; mode default";
                "e" = "exec ${pkgs.emacs}/bin/emacs; mode default";
                "${mod}+apostrophe" = "mode default";
                "Escape" = "mode default";
                "Return" = "mode default";
              };
            };
          };
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.gnome3.gnome-themes-standard;
        name = "Adwaita";
      };
      font = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans 10";
      };
      iconTheme = {
        package = pkgs.gnome3.adwaita-icon-theme;
        name = "Adwaita";
      };
    };
  };
}
