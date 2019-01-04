{
  services.tlp = {
    enable = true;
    extraConfig = ''
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
    '';
  };

  services.logind.extraConfig = ''
    # IdleAction=suspend
    # IdleActionSec=30s
    # HandlePowerKey=suspend
  '';
}
