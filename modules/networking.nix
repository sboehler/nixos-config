{
  systemd = {
    network = {
      enable = true;
      networks = {
        wireless = {
          enable = true;
          name = "wlp*";
          networkConfig = {
            DHCP = "yes";
            MulticastDNS = "yes";
            IPv6PrivacyExtensions = "yes";
          };
        };
        wired = {
          enable = true;
          name = "e*";
          networkConfig = {
            DHCP = "yes";
            MulticastDNS = "yes";
            IPv6PrivacyExtensions = "yes";
          };
        };
      };
    };
  };

  networking = {
    wireless.enable = true;
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [
        5353
        5355 # https://en.wikipedia.org/wiki/Link-Local_Multicast_Name_Resolution
      ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
  };
}
