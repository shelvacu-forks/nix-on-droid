# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ callPackage, nixpkgs }:

let
  args = callPackage ./cross-pkgs-args.nix { };
  pkgsCross = import nixpkgs args;
in
pkgsCross
