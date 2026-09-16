#!/bin/sh
# write-ios-version.sh — write this build's version into an iOS app's
# Info.plist and, optionally, its Settings bundle.
#
# Vendored from laugga/ops, share/version/, next to version.sh, which it runs.
# Edit it there, never in a copy.
#
#   write-ios-version.sh --info-plist <path>
#                        [--full-version-key <key>] [--commit-key <key>]
#                        [--settings-plist <path> --settings-key <key>]
#
#   Info.plist   CFBundleShortVersionString   the version
#                CFBundleVersion              the build number
#                <full-version-key>           the full version, if given
#                <commit-key>                 the commit, if given
#   Settings     DefaultValue of the PreferenceSpecifiers item whose Key is
#                <settings-key>: "<full version> (<build number>)"
#
# The item is found by its Key, never by position, so adding a row to Settings
# can't make this write into the wrong one.
#
# Point it at the source plists or at the built product's — that's the
# repository's choice. Source files it writes don't count as uncommitted
# changes, so writing the version doesn't make the next build -dirty.
#
# lightmate-app-ios, for instance:
#
#   write-ios-version.sh --info-plist Support/Lightmate-Info.plist \
#     --full-version-key LMReleaseFullVersionString --commit-key LMBuildGitCommit \
#     --settings-plist Resources/Settings.bundle/Root.plist --settings-key settingsVersion
#
# Whatever version.sh reads from the environment applies here too. macOS only:
# it uses plutil and PlistBuddy.
set -eu

die() { echo "write-ios-version.sh: $*" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd)
buddy=/usr/libexec/PlistBuddy

info= full_key= commit_key= settings= settings_key=
while [ $# -gt 0 ]; do
  [ $# -ge 2 ] || die "$1 needs a value"
  case $1 in
    --info-plist)       info=$2 ;;
    --full-version-key) full_key=$2 ;;
    --commit-key)       commit_key=$2 ;;
    --settings-plist)   settings=$2 ;;
    --settings-key)     settings_key=$2 ;;
    *) die "unknown option $1" ;;
  esac
  shift 2
done
[ -n "$info" ] || die "usage: write-ios-version.sh --info-plist <path> [--full-version-key <key>] [--commit-key <key>] [--settings-plist <path> --settings-key <key>]"
[ -f "$info" ] || die "no Info.plist at $info"
if [ -n "$settings$settings_key" ]; then
  [ -n "$settings" ] && [ -n "$settings_key" ] || die "--settings-plist and --settings-key go together"
  [ -f "$settings" ] || die "no Settings plist at $settings"
fi
command -v plutil >/dev/null && [ -x "$buddy" ] || die "needs plutil and $buddy — macOS only"

abs() { (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd -P)" "$(basename "$1")"); }
top=$(cd "$(git rev-parse --show-toplevel)" && pwd -P) || die "$(pwd) is not a git checkout"

# Only files inside the repository can be excluded from the dirty check — git
# rejects a pathspec outside it — and a built product's plist is never tracked.
excl=${VERSION_DIRTY_EXCLUDE:-}
for f in "$info" "$settings"; do
  [ -n "$f" ] || continue
  a=$(abs "$f")
  case $a in "$top"/*) excl=${excl:+$excl:}$a ;; esac
done

out=$(VERSION_DIRTY_EXCLUDE=$excl sh "$here/version.sh") || exit 1
eval "$out"

plutil -replace CFBundleShortVersionString -string "$VERSION" "$info"
plutil -replace CFBundleVersion -string "$BUILD_NUMBER" "$info"
[ -z "$full_key" ] || plutil -replace "$full_key" -string "$FULL_VERSION" "$info"
[ -z "$commit_key" ] || plutil -replace "$commit_key" -string "$COMMIT" "$info"

if [ -n "$settings" ]; then
  shown="$FULL_VERSION ($BUILD_NUMBER)"
  i=0
  found=
  while "$buddy" -c "Print :PreferenceSpecifiers:$i" "$settings" >/dev/null 2>&1; do
    k=$("$buddy" -c "Print :PreferenceSpecifiers:$i:Key" "$settings" 2>/dev/null || true)
    if [ "$k" = "$settings_key" ]; then
      "$buddy" -c "Set :PreferenceSpecifiers:$i:DefaultValue $shown" "$settings" 2>/dev/null \
        || "$buddy" -c "Add :PreferenceSpecifiers:$i:DefaultValue string $shown" "$settings"
      found=1
      break
    fi
    i=$((i + 1))
  done
  [ -n "$found" ] || die "no PreferenceSpecifiers item with Key '$settings_key' in $settings"
fi

echo "write-ios-version.sh: $LANE — $VERSION ($BUILD_NUMBER), $FULL_VERSION"
