{ mkDerivation, base, bifunctors, bytestring, containers
, exceptions, fetchgit, filepath, groups, hpack, megaparsec, mtl
, optparse-applicative, prettyprinter, regex-pcre, scientific
, stdenv, tasty, tasty-hunit, tasty-quickcheck, tasty-smallcheck
, text, time
}:
mkDerivation {
  pname = "beans";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/sboehler/beans";
    sha256 = "0hfsia7rs104r238p2pghwnj38wll4fhlx3y3y0c9l155f32h601";
    rev = "dd55bdf65268a3987884176fb7a24b35d6cd44cf";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bifunctors bytestring containers exceptions filepath groups
    megaparsec mtl optparse-applicative prettyprinter regex-pcre
    scientific text time
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [ base optparse-applicative ];
  testHaskellDepends = [
    base tasty tasty-hunit tasty-quickcheck tasty-smallcheck
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/sboehler/beans#readme";
  description = "A plain text accounting tool";
  license = stdenv.lib.licenses.bsd3;
}
