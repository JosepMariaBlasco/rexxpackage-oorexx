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

**Status: prototype.** Linux first; Windows and macOS later.

| Package | Release | Linux (ooRexx 5.3.0 r13312) |
|---|---|---|
| Rexx/SQL | 2.6 beta 3 | builds with SQLite 3; smoke test passes ([`rexxsql/`](rexxsql/)) |

Building Rexx/SQL needs no change to its sources, only two settings
(see [`rexxsql/build.sh`](rexxsql/build.sh)):

```sh
rexxsql/build.sh                       # downloads, configures, builds in build/rexxsql
cd build && LD_LIBRARY_PATH=$PWD/rexxsql/src rexx ../rexxsql/test/smoke.rex
```

## Licence

What is written here for a package is under that package's licence;
for Rexx/SQL, the GNU Library General Public License version 2
([`LICENSE`](LICENSE)). The packages themselves are under their own
licences, as distributed by their author.
