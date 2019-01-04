{ pkgs, stdenv }:
let
  scripts = ./scripts;
in
  pkgs.writeShellScriptBin "launch-rofi" ''
    ls ${scripts} | ${pkgs.rofi}/bin/rofi -dmenu -normal-window | xargs -I TARGET sh ${scripts}/TARGET
  ''
