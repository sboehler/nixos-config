{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./modules/vmware-vm.nix
    ];

  networking.hostName = "surfacepro-nixos";

  nix.maxJobs = 8;

  home-manager.users.silvio.xresources.properties = {
    "Xft.dpi" = 192;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/00712792-b1e2-4417-bb0c-3b01e3b83c83";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
