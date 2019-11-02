{ pkgs, config, lib, ...}:
{
  home-manager.users.silvio = {

    home = {
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

      firefox = {
        enable = true;
        profiles = {
          silvio = {};
        };
      };
    };

    services = {
      xsuspender.enable = true;
    };

    xsession = {
      enable = true;
      windowManager = {
        i3 = let
          mod = "Mod4";
        in
          {
            enable = true;
            config =  {
              inherit mod;
              fonts = ["DejaVu Sans Mono" "FontAwesome5Free 10"];
              keybindings = lib.mkOptionDefault {
                "${mod}+d" = ''exec --no-startup-id "${pkgs.rofi}/bin/rofi -combi-modi window,drun -show combi -modi combi,run"'';

                "${mod}+Control+j" = "focus left";
                "${mod}+Control+k" = "focus down";
                "${mod}+Control+l" = "focus up";
                "${mod}+Control+semicolon" = "focus right";

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
                  "e" = "exec ${pkgs.emacs}/bin/emacsclient -c; mode default";
                  "${mod}+apostrophe" = "mode default";
                  "Escape" = "mode default";
                  "Return" = "mode default";
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
  };
}
