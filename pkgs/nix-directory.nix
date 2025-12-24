# Copyright (c) 2019-2025, see AUTHORS. Licensed under MIT License, see LICENSE.

{ runCommand
, closureInfo
, prootTermux
, pkgsStatic
, nix
, cacert
, bashNonInteractive
, config
}:

let
  static-nix = pkgsStatic.nix; #.overrideAttrs { version = "omitted"; };

  info = closureInfo {
    rootPaths = [
      prootTermux
      static-nix
      nix
      cacert
      bashNonInteractive
      config.build.activationPackage
    ];
  };
in
runCommand "nix-directory" { } ''
  # create nix state directory to satisfy nix heuristics to recognize the manual created /nix directory as a valid nix store
  mkdir -p build/nix/var/nix/db
  mkdir -p build/nix/store

  for i in $(< ${info}/store-paths); do
    cp --archive "$i" "build$i"
  done

  mkdir -p $out/nix-support
  cp --recursive build/nix/store $out/store
  cp --recursive build/nix/var $out/var
  cp ${info}/registration $out/var/registration
  cat > $out/nix-support/package-info.nix <<EOF
  {
    bash = "${bashNonInteractive}";
    cacert = "${cacert}";
    nix = "${nix}";
  }
  EOF
''
