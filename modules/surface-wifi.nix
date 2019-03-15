{stdenv, pkgs}:
stdenv.mkDerivation {
  name = "surface-wifi-firmware";
  src = ./surface-wifi;
  priority = 1;
  installPhase = ''
    mkdir -p $out/lib/firmware/ath10k
    cp -r $src/* $out/lib/firmware/ath10k
  '';
}
