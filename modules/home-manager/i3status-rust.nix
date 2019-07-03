{ pkgs, ... }:
let
  configFile = pkgs.writeText "status.toml" ''
    theme = "modern"
    icons = "awesome"

    [[block]]
    block = "focused_window"
    max_width = 40

    [[block]]
    block = "music"
    buttons = ["play", "next"]

    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{Mug}G/{MTg}G"

    [[block]]
    block = "cpu"
    interval = 1

    [[block]]
    block = "battery"
    interval = 10
    format = "{percentage}% {time}"

    [[block]]
    block = "sound"
    on_click = "${pkgs.pavucontrol}/bin/pavucontrol"

    [[block]]
    block = "backlight"

    [[block]]
    block = "toggle"
    text = "Inhibit"
    command_state = "${pkgs.xorg.xset}/bin/xset q | grep Disabled"
    command_on = "${pkgs.xorg.xset}/bin/xset s off -dpms"
    command_off = "${pkgs.xorg.xset}/bin/xset s default +dpms"
    interval = 5

    [[block]]
    block = "time"
    interval = 60
    format = "%a %d %b %R"
  '';

in
  {
    home-manager.users.silvio = {
      home.packages = [pkgs.i3status-rust];
      xdg.configFile."i3/status.toml" = {
        source = configFile;
      };
    };
  }
