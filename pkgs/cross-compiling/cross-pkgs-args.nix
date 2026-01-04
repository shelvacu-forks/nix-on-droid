# Copyright (c) 2019-2025, see AUTHORS. Licensed under MIT License, see LICENSE.

{ lib, stdenv, targetSystem, proot-termux-src }:

let
  arch = lib.strings.removeSuffix "-linux" targetSystem;
in
{
  inherit (stdenv.hostPlatform) system;

  crossSystem = {
    config = "${arch}-unknown-linux-android";
    androidSdkVersion = "35";
    androidNdkVersion = "27";
    libc = "bionic";
    useAndroidPrebuilt = false;
    useLLVM = true;
    isStatic = true;
  };

    overlays = [ (new: old:
      { libuv = old.libuv.overrideAttrs { doCheck = false; }; }
      // old.lib.optionalAttrs (proot-termux-src != null) { inherit proot-termux-src; }
    ) ];
}
