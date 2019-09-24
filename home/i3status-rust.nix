{ pkgs, lib, config, ... }:
with lib;
let
  configFile = enableBattery: enableBacklight: enableAudio: enableRealHardware: (''
    theme = "modern"
    icons = "awesome"

    [[block]]
    block = "focused_window"
    max_width = 40
'' + (if enableAudio
      then ''
    [[block]]
    block = "music"
    max_width = 0
    buttons = ["prev", "play", "next"]
    ''
      else "\n")
+ ''
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
(if enableAudio
 then ''
    [[block]]
    block = "sound"
    on_click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
    ''
 else "\n")
+
(if enableBacklight then ''
    [[block]]
    block = "backlight"
      ''
 else "\n")
+ (if enableRealHardware then ''
    [[block]]
    block = "toggle"
    text = "Inhibit"
    command_state = "${pkgs.xorg.xset}/bin/xset q | grep Disabled"
    command_on = "${pkgs.xorg.xset}/bin/xset s off -dpms && ${pkgs.xautolock}/bin/xautolock -disable"
    command_off = "${pkgs.xorg.xset}/bin/xset s default +dpms && ${pkgs.xautolock}/bin/xautolock -enable"
    interval = 5''
   else "\n")
+ ''
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
    audio = mkEnableOption "audio";
    realHardware = mkEnableOption "realHardware";
  };

  config = {
    home-manager.users.silvio = {
      home.packages = [pkgs.i3status-rust];
      xdg.configFile."i3/status.toml" = {
        source = pkgs.writeText "status.toml" (configFile
          config.battery
          config.backlight
          config.audio
          config.realHardware);
      };
    };
  };
}
