with import <nixpkgs> {};

let
  manyLinuxFile =
    writeTextDir "_manylinux.py"
      ''
        print("in _manylinux.py")
        manylinux1_compatible = True
      ''; in

buildFHSUserEnv {
  name = "my-python-env";
  targetPkgs = pkgs: with pkgs; [
    python3
    pipenv
    which
    gcc
    binutils
    freetype
    freetype.dev
    gfortran
    pkgconfig
    libpng
    libpng.dev
    zlib
    suitesparse
    blas
    liblapack

    # All the C libraries that a manylinux_1 wheel might depend on:
    ncurses
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libICE
    xorg.libSM
    glib
  ];

  profile = ''
    export PYTHONPATH=${manyLinuxFile.out}:/usr/lib/python3.7/site-packages
  '';

  runScript = "$SHELL";
}
