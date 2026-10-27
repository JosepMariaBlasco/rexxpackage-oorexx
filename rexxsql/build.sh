#!/bin/sh
# Build Rexx/SQL 2.6 beta 3 against ooRexx, with SQLite 3, on Linux or
# macOS. (Windows: build-windows.ps1.)
#
# Downloads the author's source release (pinned by checksum), configures
# it for ooRexx and builds it. Nothing in the sources is changed; these
# settings are all that is needed:
#
#   OOREXX_40       selects the ooRexx 4.0+ API definitions in the
#                   sources' headers. `configure` defines it only when
#                   `oorexx-config` reports version 4; ooRexx 5 does not
#                   ship `oorexx-config`, so it is passed in CFLAGS.
#   --with-dblibdir points `configure` at where libsqlite3 is today
#                   (Linux: the multiarch directory; macOS: the SDK).
#   macOS only:     where ooRexx and SQLite's headers are, and
#                   -Wno-error for the warnings that current clang
#                   reports as errors by default.
#
# Requirements: ooRexx (headers and librexxapi), a C compiler, make,
# unzip, curl; on Linux, the SQLite 3 development files (libsqlite3-dev).
# On macOS, REXX_HOME must name ooRexx's folder (with include and lib);
# elsewhere it is optional (default: configure's own search).
#
# Usage: rexxsql/build.sh [WORKDIR]     (default: ./build/rexxsql)
#
# This file is under the GNU Library General Public License version 2,
# the licence of Rexx/SQL (see LICENSE in this folder).

set -eu

VERSION=2.6B3
ZIP=rxsql26B3_src.zip
URL="https://downloads.sourceforge.net/project/rexxsql/rexxsql/2.6/$ZIP"
SHA256=57e5b7082ce141820c0fd6c8a26e0c82da8b625f090ff454497d62fd1f8e59e8

WORK=${1:-build/rexxsql}
CFLAGS="-O2 -DOOREXX_40"
set --

case $(uname -s) in
  Darwin)
    if [ -z "${REXX_HOME:-}" ]; then
      echo "REXX_HOME must name the ooRexx folder (bin, include, lib)" >&2
      exit 2
    fi
    SDK=$(xcrun --show-sdk-path)
    set -- --with-dbincdir="$SDK/usr/include" --with-dblibdir="$SDK/usr/lib"
    CFLAGS="$CFLAGS -Wno-error=incompatible-function-pointer-types"
    CFLAGS="$CFLAGS -Wno-error=incompatible-pointer-types"
    CFLAGS="$CFLAGS -Wno-error=implicit-int"
    CFLAGS="$CFLAGS -Wno-error=implicit-function-declaration"
    CFLAGS="$CFLAGS -Wno-error=int-conversion"
    ;;
  *)
    SQLITE_LIBDIR=${SQLITE_LIBDIR:-$(dirname "$(${CC:-gcc} -print-file-name=libsqlite3.so)")}
    set -- --with-dblibdir="$SQLITE_LIBDIR"
    ;;
esac
if [ -n "${REXX_HOME:-}" ]; then
  set -- "$@" --with-rexxincdir="$REXX_HOME/include" --with-rexxlibdir="$REXX_HOME/lib"
fi

mkdir -p "$WORK"
WORK=$(cd "$WORK" && pwd)
cd "$WORK"

if [ ! -f "$ZIP" ]; then
  curl -fsSL -o "$ZIP" "$URL"
fi
if command -v sha256sum >/dev/null 2>&1; then
  echo "$SHA256  $ZIP" | sha256sum -c -
else
  echo "$SHA256  $ZIP" | shasum -a 256 -c -
fi

rm -rf src
mkdir src
unzip -q "$ZIP" -d src
cd src
chmod +x configure install-sh common/config.guess common/config.sub

echo "configure: CFLAGS=\"$CFLAGS\" --with-rexx=oorexx --with-db=sqlite3 $*"
CFLAGS="$CFLAGS" ./configure --with-rexx=oorexx --with-db=sqlite3 "$@"
make

echo "Built Rexx/SQL $VERSION for ooRexx in $WORK/src:"
ls -l librexxsql.* rexxsql
