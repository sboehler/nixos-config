{
  services.tlp.enable = true;

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30s
    HandlePowerKey=suspend
  '';
}
