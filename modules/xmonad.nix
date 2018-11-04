{ mkDerivation, base, containers, data-default, directory
, extensible-exceptions, filepath, mtl, process, QuickCheck
, setlocale, stdenv, unix, utf8-string, X11
}:
mkDerivation {
  pname = "xmonad";
  version = "0.15";
  sha256 = "4a7948e6eee5e34a27d15444589ade3b3fa1adecadbf37b943cff8348380f928";
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base containers data-default directory extensible-exceptions
    filepath mtl process setlocale unix utf8-string X11
  ];
  executableHaskellDepends = [ base mtl unix X11 ];
  testHaskellDepends = [
    base containers extensible-exceptions QuickCheck X11
  ];
  patches = [./xmonad-nix.patch];
  postInstall = ''
    install -D man/xmonad.1 $doc/share/man/man1/xmonad.1
    install -D man/xmonad.hs $doc/share/doc/$name/sample-xmonad.hs
  '';
  homepage = "http://xmonad.org";
  description = "A tiling window manager";
  license = stdenv.lib.licenses.bsd3;
}
