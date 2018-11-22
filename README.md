# nixos-config

Top-level files correspond to the different machines. I check out this repository in my local home directory and symlink /etc/nixos/connfiguration.nix to these files:

- pocket.nix: GPD Pocket Laptop
- xps13.nix: Dell XPS13 9350 Laptop
- xps15.nix: Dell XPS15 9560 Laptop
- work-pc.nix: My office PC, some no-name machine with Core i7 and nVidia graphics
- server.nix: HP ProLiant MicroServer N36L with a BTRFS RAID1 setup

Implementation details (as of 2018-05):
- All drives use BTRFS on LVM on dm-crypt.
- The server offers root drive decryption via SSH on the initrd (see initrd-ssh.nix) as it runs headless in the basement.
- I use NixOS unstable at the moment.
- Lots of ideas for the GPD Pocket were inspired by [this repository](https://github.com/andir/nixos-gpd-pocket), in particular regarding the kernel options.
- The GPD Pocket requires (as of 4.17.5) a custom kernel configuration. It is setup to remotely build expensive stuff on the XPS 15.
- Instead of using channels directly I have the nixpkgs repository checked out as /nix/nixpkgs (usually tracking stable). [This article](https://matrix.ai/2017/03/13/intro-to-nix-channels-and-reproducible-nixos-environment/) was very helpful when I set everything up.
