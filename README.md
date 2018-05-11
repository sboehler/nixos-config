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
- I use NixOS stable, except for the GPD pocket which currently runs NixOS unstable.
- The GPD Pocket requires (as of 4.17-rc4) a custom kernel configuration. It is setup to remotely build expensive stuff on the XPS 15.
