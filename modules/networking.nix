{
  networking = {
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [
        5355 # https://en.wikipedia.org/wiki/Link-Local_Multicast_Name_Resolution
      ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
  };
}
