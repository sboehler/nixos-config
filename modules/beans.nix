{ mkDerivation, base, bifunctors, bytestring, containers
, exceptions, fetchgit, filepath, groups, megaparsec, mtl
, optparse-applicative, prettyprinter, regex-pcre, scientific
, stdenv, tasty, tasty-golden, tasty-hunit, tasty-quickcheck
, tasty-smallcheck, text, time
}:
mkDerivation {
  pname = "beans";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/sboehler/beans";
    sha256 = "1xjd3fq3iqfxfk2wx3qhdkl0hssxpcphpmvwysjv9zwlxnpsrxhc";
    rev = "2b088e7325ec73058ac91277df0b5403fcbd2bff";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bifunctors bytestring containers exceptions filepath groups
    megaparsec mtl optparse-applicative prettyprinter regex-pcre
    scientific text time
  ];
  executableHaskellDepends = [ base optparse-applicative ];
  testHaskellDepends = [
    base bytestring filepath megaparsec mtl regex-pcre tasty
    tasty-golden tasty-hunit tasty-quickcheck tasty-smallcheck text
    time
  ];
  homepage = "https://github.com/sboehler/beans#readme";
  description = "A plain text accounting tool";
  license = stdenv.lib.licenses.bsd3;
}
