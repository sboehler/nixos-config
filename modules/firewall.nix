{
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        22000
      ];
      allowedUDPPorts = [
        21027 # Syncthing discovery
        5353
        5355 # https://en.wikipedia.org/wiki/Link-Local_Multicast_Name_Resolution
      ];
    };
  };
}
