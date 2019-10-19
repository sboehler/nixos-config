{ config, pkgs, lib, ... }:
{
  imports =
    [
      <home-manager/nixos>
      ./modules/vm.nix
    ];

  hostHostName = "xps15";

  networking.hostName = "xps15-nixos";

  nix.maxJobs = 8;

  home-manager.users.silvio.xresources.properties = {
    "Xft.dpi" = 192;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0ef93bd6-5b86-47be-99eb-35baf1c61124";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AAAD-2109";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
