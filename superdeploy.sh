#!/usr/bin/env bash
source shellvaculib.bash || exit 1

svl_no_args $#

svl_assert_probably_in_script_dir

declare app_id="com.termux.nix"

adb shell pm clear "$app_id"
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

# set soft_keyboard_enabled=true in shared preferences
declare sed_script='/^<\/map>$/ i\    <boolean name="soft_keyboard_enabled" value="false" />'
declare edit_shared_prefs_command
printf -v edit_shared_prefs_command "su root sed -i -e%q /data/data/$app_id/shared_prefs/${app_id}_preferences.xml" "$sed_script"
adb shell -- "$edit_shared_prefs_command"

#allow notifications
adb shell 'pm grant com.termux.nix android.permission.POST_NOTIFICATIONS'

#launch
adb shell 'am start $(cmd package resolve-activity --brief com.termux.nix | tail -n 1)'
