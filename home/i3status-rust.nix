{ pkgs, lib, config, ... }:
with lib;
let
  configFile = enableBattery: enableBacklight: (''
    theme = "modern"
    icons = "awesome"

    [[block]]
    block = "focused_window"
    max_width = 40

    [[block]]
    block = "music"
    buttons = ["play", "next"]

    [[block]]
    block = "disk_space"
    path = "/"
    alias = "/"
    info_type = "available"
    unit = "GB"
    interval = 20
    show_percentage = true

    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{Mug}G/{MTg}G"

    [[block]]
    block = "cpu"
    interval = 1
    ''
  +
  (if enableBattery
   then ''
    [[block]]
    block = "battery"
    driver = "upower"
    device = "DisplayDevice"
    interval = 10
    format = "{percentage}% {time}"
    ''
   else "\n")
  +
  ''
    [[block]]
    block = "sound"
    on_click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
    ''
  +
  (if enableBacklight then ''
    [[block]]
    block = "backlight"
      ''
   else "\n")
  + ''
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
  '');

in
{
  options = {
    battery = mkEnableOption "battery";
    backlight = mkEnableOption "backlight";
  };

  config = {
    home-manager.users.silvio = {
      home.packages = [pkgs.i3status-rust];
      xdg.configFile."i3/status.toml" = {
        source = pkgs.writeText "status.toml" (configFile config.battery config.backlight);
      };
    };
  };
}
