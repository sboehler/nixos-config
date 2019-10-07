{ config, pkgs, lib, ... }:
{
  imports =
    [
      <home-manager/nixos>
      ./modules/vm.nix
    ];

  nix.maxJobs = 4;

  networking.hostName = "surface-nixos";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9673761a-caf2-4329-ba53-0a1a883a1228";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0328-BCA3";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
