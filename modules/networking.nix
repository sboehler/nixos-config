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
          dhcpConfig = {
            RouteMetric = 20;
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
          dhcpConfig = {
            RouteMetric = 10;
          };
        };
      };
    };
  };

  networking = {
    wireless = {
      enable = true;
      userControlled = {
        enable = true;
      };
    };
    enableIPv6 = true;
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
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
  };
}
