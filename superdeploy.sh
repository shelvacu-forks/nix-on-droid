#!/usr/bin/env bash
source shellvaculib.bash || exit 1

svl_no_args $#

svl_assert_probably_in_script_dir

rm -rf n-o-d
mkdir n-o-d
git -C . archive --format=tar.gz --prefix n-o-d/ HEAD > n-o-d/archive.tar.gz
ARCHES=x86_64 nix run '.#deploy' -- file:///data/local/tmp/n-o-d/archive.tar.gz n-o-d/
# tar cf n-o-d.tar n-o-d
adb shell 'rm -rf /data/local/tmp/n-o-d'
adb push n-o-d /data/local/tmp/
echo 'pushed'
adb shell 'cd /data/local/tmp/n-o-d && tar xzof archive.tar.gz && mv n-o-d unpacked'
echo 'unpacked'

