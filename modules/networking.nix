{
  networking = {
    enableIPv6 = true;
    firewall = {
      enable = true;
    };
  };
  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
    # "net.ipv4.ip_forward" = 1;
  };
}
