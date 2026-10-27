#!/bin/sh
# Build Rexx/SQL 2.6 beta 3 against ooRexx, with SQLite 3, on Linux.
#
# Downloads the author's source release (pinned by checksum), configures
# it for ooRexx and builds it. Nothing in the sources is changed: the two
# settings below are all that is needed.
#
#   OOREXX_40       selects the ooRexx 4.0+ API definitions in the
#                   sources' headers. `configure` defines it only when
#                   `oorexx-config` reports version 4; ooRexx 5 does not
#                   ship `oorexx-config`, so it is passed in CFLAGS.
#   --with-dblibdir points `configure` at the multiarch directory where
#                   current distributions keep libsqlite3.
#
# Requirements: ooRexx installed (headers and librexxapi), gcc, make,
# unzip, curl, and the SQLite 3 development files (libsqlite3-dev).
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
SQLITE_LIBDIR=${SQLITE_LIBDIR:-$(dirname "$(gcc -print-file-name=libsqlite3.so)")}

mkdir -p "$WORK"
WORK=$(cd "$WORK" && pwd)
cd "$WORK"

if [ ! -f "$ZIP" ]; then
  curl -fsSL -o "$ZIP" "$URL"
fi
echo "$SHA256  $ZIP" | sha256sum -c -

rm -rf src
mkdir src
unzip -q "$ZIP" -d src
cd src
chmod +x configure install-sh common/config.guess common/config.sub

CFLAGS="-O2 -DOOREXX_40" ./configure \
  --with-rexx=oorexx \
  --with-db=sqlite3 \
  --with-dblibdir="$SQLITE_LIBDIR"
make

echo "Built Rexx/SQL $VERSION for ooRexx in $WORK/src:"
ls -l librexxsql.so rexxsql
