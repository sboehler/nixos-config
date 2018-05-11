{pkgs}:
let
  txt = ./brcmfmac4356-pcie.txt;
  bin = ./brcmfmac4356-pcie.bin;
in
(pkgs.runCommand "gpd-pocket-wifi" {} ''
  mkdir -p $out/lib/firmware/brcm
  cp ${txt} $out/lib/firmware/brcm/brcmfmac4356-pcie.txt
  cp ${bin} $out/lib/firmware/brcm/brcmfmac4356-pcie.bin
'')
