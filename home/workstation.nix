{ pkgs, config, lib, ...}
: {
  imports = [
    <home-manager/nixos>
    ./i3status-rust.nix
  ];

  home-manager.users.silvio = {

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

    programs.firefox = {
      enable = true;
      profiles = {
        silvio = {
          userChrome = ''
          #TabsToolbar { visibility: collapse !important; }
          '';
        };
      };
    };

    programs.gnome-terminal = {
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

    services.xsuspender.enable = true;

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

    xsession = {
      enable = true;
      windowManager.i3.enable = true;
      windowManager.i3.config = rec {
        modifier = "Mod4";
        fonts = ["DejaVu Sans Mono" "FontAwesome5Free 10"];
        keybindings = lib.mkOptionDefault {
          "${modifier}+d" = ''exec --no-startup-id "${pkgs.rofi}/bin/rofi -combi-modi window,drun -show combi -modi combi,run"'';
          "XF86Search" = ''exec --no-startup-id "${pkgs.rofi}/bin/rofi -combi-modi window,drun -show combi -modi combi,run"'';

          "${modifier}+j" = "focus left";
          "${modifier}+k" = "focus down";
          "${modifier}+l" = "focus up";
          "${modifier}+semicolon" = "focus right";

          "${modifier}+Left" = "move workspace to output left";
          "${modifier}+Down" = "move workspace to output down";
          "${modifier}+Up" = "move workspace to output up";
          "${modifier}+Right" = "move workspace to output right";

          "${modifier}+Shift+j" = "move left 40px";
          "${modifier}+Shift+k" = "move down 40px";
          "${modifier}+Shift+l" = "move up 40px";
          "${modifier}+Shift+semicolon" = "move right 40px";

          "${modifier}+Shift+Left" = "move container to output left";
          "${modifier}+Shift+Down" = "move container to output down";
          "${modifier}+Shift+Up" = "move container to output up";
          "${modifier}+Shift+Right" = "move container to output right";

          "${modifier}+a" = "focus parent";
          "${modifier}+q" = "focus child";

          "${modifier}+u" = "workspace prev_on_output";
          "${modifier}+i" = "workspace next_on_output";

          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "${modifier}+Shift+Control+l" = "exec loginctl lock-session";
          "${modifier}+Shift+e" = "exit";

          "${modifier}+p" = "exec ${pkgs.gopass}/bin/gopass ls --flat | ${pkgs.rofi}/bin/rofi -dmenu -p 'Select password' | ${pkgs.findutils}/bin/xargs --no-run-if-empty gopass show -c";
          "${modifier}+o" = "exec ${pkgs.gopass}/bin/gopass ls --flat | ${pkgs.rofi}/bin/rofi -dmenu -p 'Select OTP' | ${pkgs.findutils}/bin/xargs --no-run-if-empty gopass otp -c";

          "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1.5% && killall -SIGUSR1 i3status";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1.5% && killall -SIGUSR1 i3status";
          "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "${modifier}+Print" = "exec ${pkgs.gnome3.gnome-screenshot}/bin/gnome-screenshot -i";
        };

        modes = lib.mkOptionDefault {
          resize = {
            "j" = "resize shrink width 10 px or 10 ppt";
            "k" = "resize grow height 10 px or 10 ppt";
            "l" = "resize shrink height 10 px or 10 ppt";
            "semicolon" = "resize grow width 10 px or 10 ppt";
            "${modifier}+r" = "mode default";
          };
        };

        bars = [
          {
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3/status.toml";
            fonts = ["DejaVu Sans Mono" "FontAwesome5Free 10"];
            position = "top";
            colors = {
              separator = "#666666";
              background = "#222222";
              statusline = "#dddddd";
              focusedWorkspace = {
                border = "#0088CC";
                background = "#0088CC";
                text = "#ffffff";
              };
              activeWorkspace = {
                border = "#333333";
                background = "#333333";
                text = "#ffffff";
              };
              inactiveWorkspace = {
                border = "#333333";
                background = "#333333";
                text = "#888888";
              };
              urgentWorkspace = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
            };
          }
        ];
      };
      windowManager.i3.extraConfig = ''
          focus_wrapping no
          bindsym --release button2 kill
          bindsym button3 floating toggle
          client.unfocused        #333333 #222222 #eeeeee #292d2e   #222222
        '';
    };
  };
}
