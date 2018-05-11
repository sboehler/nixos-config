{pkgs, ...}:
{
  hardware.enableAllFirmware = true;
  hardware.firmware = [
    (pkgs.callPackage ./brcmfmac4356-pcie.nix {})
  ];
}
