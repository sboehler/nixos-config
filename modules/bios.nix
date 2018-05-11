{
  boot = {
    loader = {
      timeout = 10;
      grub = {
        enable = true;
        version = 2;
        splashImage = null;
        devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd"];
      };
    };
  };
}
