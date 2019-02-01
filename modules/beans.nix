{ mkDerivation, base, bifunctors, bytestring, containers, Decimal
, exceptions, fetchgit, filepath, groups, hpack, lens, megaparsec
, mtl, optparse-applicative, parser-combinators, prettyprinter
, regex-pcre, scientific, stdenv, tasty, tasty-golden, tasty-hunit
, tasty-quickcheck, tasty-smallcheck, text, time
}:
mkDerivation {
  pname = "beans";
  version = "0.0.3.0";
  src = fetchgit {
    url = "https://github.com/sboehler/beans";
    sha256 = "0k8cmy9063pi5fniahzbq9phabin3j0njak2y182ap8yhcjlc33y";
    rev = "6bfa88da0b882a517c661dadbf1548e38135b2c1";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bifunctors bytestring containers Decimal exceptions filepath
    groups lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre scientific tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bifunctors bytestring containers Decimal exceptions filepath
    groups lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre scientific tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  testHaskellDepends = [
    base bifunctors bytestring containers Decimal exceptions filepath
    groups lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre scientific tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/sboehler/beans#readme";
  description = "A plain text accounting tool";
  license = stdenv.lib.licenses.bsd3;
}
