# Copyright (c) 2019-2025, see AUTHORS. Licensed under MIT License, see LICENSE.

{ stdenv
, fetchFromGitHub
, talloc
, nonAndroidGcc
, static ? true
, outputBinaryName ? "proot-static"
, proot-termux-src ? null
}:

stdenv.mkDerivation {
  pname = "proot-termux";
  version = "0-unstable-2025-10-19";

  src =
    if proot-termux-src != null then
      proot-termux-src
    else
  fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "228a5f28b078f4e2504de46758ce17948f73f507";
    sha256 = "sha256-ViV8i7W47dEgYDKPN1w4tY+XaVHcXLWxTGTX3wKdARk=";
  };

  patches = [
    ./detranslate-empty.patch
    # ./trust-the-sigsys.patch
  ];

  # ashmem.h is rather small, our needs are even smaller, so just define these:
  preConfigure = ''
    mkdir -p fake-ashmem/linux; cat > fake-ashmem/linux/ashmem.h << EOF
    #include <linux/limits.h>
    #include <linux/ioctl.h>
    #include <string.h>
    #define __ASHMEMIOC 0x77
    #define ASHMEM_NAME_LEN 256
    #define ASHMEM_SET_NAME _IOW(__ASHMEMIOC, 1, char[ASHMEM_NAME_LEN])
    #define ASHMEM_SET_SIZE _IOW(__ASHMEMIOC, 3, size_t)
    #define ASHMEM_GET_SIZE _IO(__ASHMEMIOC, 4)
    EOF
    substituteInPlace src/arch.h --replace-fail \
      '#define HAS_LOADER_32BIT true' \
      ""
    ! (grep -F '#define HAS_LOADER_32BIT' src/arch.h)
  '';
  buildInputs = [ talloc ];
  hardeningDisable = [ "zerocallusedregs" ];
  makeFlags = [ "-Csrc" "V=1" ];
  CFLAGS = [ "-O3" "-I../fake-ashmem" ] ++
    (if static then [ "-static" ] else [ ])
    ;
  LDFLAGS = (if static then [ "-static" ] else [ ]);
  LOADER_LDFLAGS = [ "-fuse-ld=${nonAndroidGcc}/bin/ld.gold" ];
  preInstall = "${stdenv.cc.targetPrefix}strip src/proot";
  installPhase = "install -D -m 0755 src/proot $out/bin/${outputBinaryName}";

  meta.mainProgram = outputBinaryName;
}
