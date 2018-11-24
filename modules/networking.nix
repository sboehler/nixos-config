{
  networking = {
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [
        5353  # mDNS
      ];
      extraCommands = ''
        # allow multicast
        iptables -A nixos-fw -d 224.0.0.0/4 -j nixos-fw-accept
      '';
    };
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
    # "net.ipv4.ip_forward" = 1;
  };
}
