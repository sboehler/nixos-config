# nixos-config

Top-level files correspond to the different machines. I check out this repository in my local home directory and symlink /etc/nixos/connfiguration.nix to these files:

- pocket.nix: GPD Pocket Laptop
- surface.nix: Microsoft Surface Go (8G/128G version), see [writeup](https://www.reddit.com/r/SurfaceLinux/comments/b31xxd/nixos_on_the_surface_go/)
- xps13.nix: Dell XPS13 9350 Laptop
- xps15.nix: Dell XPS15 9560 Laptop
- work-pc.nix: My office PC, some no-name machine with Core i7 and nVidia graphics
- server.nix: HP ProLiant MicroServer N36L with a BTRFS RAID1 setup

Implementation details:
- All drives use either BTRFS on LVM on dm-crypt or otherwise BTRFS on dm-crypt without LVM, with separate encrypted swap. The EFI partition is mounted directly as /boot.
- The server offers root drive decryption via SSH on the initrd (see initrd-ssh.nix) as it runs headless in the basement.
- Configuration is for NixOS unstable
- Lots of ideas for the GPD Pocket were inspired by [this repository](https://github.com/andir/nixos-gpd-pocket), in particular regarding the kernel options.
- The GPD Pocket requires a custom kernel configuration. It is setup to remotely build expensive stuff on the XPS 15.
- Instead of using channels directly I have the nixpkgs repository checked out as /nix/nixpkgs (usually tracking stable). [This article](https://matrix.ai/blog/intro-to-nix-channels-and-reproducible-nixos-environment/) was very helpful when I set everything up.
