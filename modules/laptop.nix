{
  services.tlp.enable = true;

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=60s
    HandlePowerKey=suspend
  '';
}
