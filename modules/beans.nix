{ mkDerivation, base, bifunctors, bytestring, containers
, exceptions, fetchgit, filepath, groups, hpack, lens, megaparsec
, mtl, optparse-applicative, parser-combinators, prettyprinter
, regex-pcre, stdenv, tasty, tasty-golden, tasty-hunit
, tasty-quickcheck, tasty-smallcheck, text, time
}:
mkDerivation {
  pname = "beans";
  version = "0.0.4.0";
  src = fetchgit {
    url = "https://github.com/sboehler/beans";
    sha256 = "1dmkk9qcwacfy192hy1inm1vf4za6g7jr1f1pkay2sfwjicybsny";
    rev = "0466d13b79ece6ec6ad1859ea8ff0a32d5c16430";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bifunctors bytestring containers exceptions filepath groups
    lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base bifunctors bytestring containers exceptions filepath groups
    lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  testHaskellDepends = [
    base bifunctors bytestring containers exceptions filepath groups
    lens megaparsec mtl optparse-applicative parser-combinators
    prettyprinter regex-pcre tasty tasty-golden tasty-hunit
    tasty-quickcheck tasty-smallcheck text time
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/sboehler/beans#readme";
  description = "A plain text accounting tool";
  license = stdenv.lib.licenses.bsd3;
}
