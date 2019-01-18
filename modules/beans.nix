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
    sha256 = "1vh9czsz14fjq5xvsfiybyvpnh57qchgljnw40am47dbz95jl9mn";
    rev = "c3a119b5b8935aa811a5bad5f3d4698bb8559293";
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
