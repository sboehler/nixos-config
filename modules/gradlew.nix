# creates an FHS user environment which
# allows execution of the gradle wrapper
# and downloaded node.js binaries

{ pkgs }:
(pkgs.buildFHSUserEnv {
  name = "gw";
  targetPkgs = Pkgs: (with pkgs;
  [
    stdenv.cc.cc.lib
    docker_compose
    openjdk10
    stdenv.cc
    docker
    git
    zsh
    ]);
  profile = ''
    export JAVA_HOME=${pkgs.openjdk10.home}
  '';
  runScript = "./gradlew";
  })
