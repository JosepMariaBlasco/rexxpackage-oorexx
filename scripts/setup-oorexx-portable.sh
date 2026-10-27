#!/bin/sh
# Download and unpack SourceForge's portable build of ooRexx for one
# platform, at the revision in the file `oorexx-revision` at the root of
# this repository, and print the folder it creates (with bin, include and
# lib).
#
#   scripts/setup-oorexx-portable.sh <platform> <dir>
#
# <platform> is the part of SourceForge's file name after the revision:
# windows.x86_64, macos.arm64.x86_64, ...
#
# This file is under the GNU Library General Public License version 2
# (see LICENSE at the root of this repository).

set -eu
[ $# -eq 2 ] || { echo "usage: $0 <platform> <dir>" >&2; exit 2; }
platform=$1
dir=$2
root=$(cd "$(dirname "$0")/.." && pwd)
rev=$(tr -d ' \r\n' < "$root/oorexx-revision")
name="oorexx-5.3.0-$rev.$platform-portable-release"

mkdir -p "$dir"
curl -fsSL -o "$dir/$name.zip" \
  "https://downloads.sourceforge.net/project/oorexx/oorexx/5.3.0beta/portable/$name.zip"
if command -v unzip >/dev/null 2>&1; then
  unzip -q -o "$dir/$name.zip" -d "$dir" >&2
else
  7z x -y -o"$dir" "$dir/$name.zip" >&2
fi
rm -f "$dir/$name.zip"
[ -d "$dir/$name/bin" ] || { echo "$dir/$name/bin not found" >&2; exit 1; }
echo "$dir/$name"
