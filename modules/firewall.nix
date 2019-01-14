{
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [
        5353 # mDNS
        5355 # https://en.wikipedia.org/wiki/Link-Local_Multicast_Name_Resolution
      ];
    };
  };
}
