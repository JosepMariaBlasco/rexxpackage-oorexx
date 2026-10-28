# rexxpackage-oorexx

Build scripts for Mark Hessling's Rexx packages against
[ooRexx](https://sourceforge.net/projects/oorexx/).

Mark Hessling's packages (Rexx/SQL, Rexx/CURL, Rexx/DW, THE and more;
see <https://hessling-editor.sourceforge.net/>) are written to work with
several Rexx interpreters. This repository holds what it takes to build
them against current ooRexx (5.3.0 beta) on today's systems: scripts
that download each package's official release, configure it for ooRexx
and build it, with the smallest change possible (configuration first).

The packages' sources are not in this repository: they are downloaded
from the author's releases, version and checksum pinned.

Rexx/SQL is a database-independent interface (SQLite, MySQL, ODBC and
others) through external functions, usable from classic Rexx and ooRexx
alike; for an object-oriented interface to SQLite only, see
[ooSQLite](https://github.com/JosepMariaBlasco/oosqlite).

**Status: prototype.**

The ooRexx used everywhere is SourceForge's 5.3.0 beta build at the
revision in [`oorexx-revision`](oorexx-revision) (today r13324).

| Package | Release | Linux x86_64 | macOS arm64, x86_64 | Windows x64 |
|---|---|---|---|---|
| Rexx/SQL | 2.6 beta 3 | ✓ | ✓ | ✓ |

✓: builds with SQLite 3 and passes the smoke test, in the
[CI](.github/workflows/rexxsql.yml), which keeps the binaries as artifacts.

### Rexx/SQL

No change to its sources; only settings (each explained in the scripts):

- Linux and macOS: [`rexxsql/build.sh`](rexxsql/build.sh), the package's
  `configure` with `--with-rexx=oorexx` and `-DOOREXX_40`; on macOS, also
  a few settings for current clang and the SDK's SQLite.
- Windows: [`rexxsql/build-windows.ps1`](rexxsql/build-windows.ps1), the
  package's `vcwin64.mak` with `INT=OOREXX4`, pointed at ooRexx 5's
  folders, and SQLite built from its official amalgamation.

```sh
rexxsql/build.sh            # downloads, configures, builds in build/rexxsql
cd build && LD_LIBRARY_PATH=$PWD/rexxsql/src rexx ../rexxsql/test/smoke.rex
```

## Licence

What is written here for a package is under that package's licence;
for Rexx/SQL, the GNU Library General Public License version 2
([`LICENSE`](LICENSE)). The packages themselves are under their own
licences, as distributed by their author.
