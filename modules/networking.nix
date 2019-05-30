{
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      extraConfig = ''
       [main]
       rc-manager=resolvconf
       '';
    };
    enableIPv6 = true;
  };
}
