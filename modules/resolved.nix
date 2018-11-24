{
  services.resolved = {
    enable = true;
    # dnssec = "false";
    extraConfig = ''
      MulticastDNS=true
    '';
  };
}
