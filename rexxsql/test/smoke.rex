/* Smoke test for Rexx/SQL built against ooRexx, with SQLite 3.          */
/*                                                                       */
/* Loads the external functions, creates a table in a scratch database,  */
/* inserts two rows, reads them back and checks every value strictly.    */
/* Exit code 0 when every check passes, 1 otherwise.                     */
/*                                                                       */
/* Usage: rexx smoke.rex [database-file]   (librexxsql.so must be found  */
/*        by the dynamic loader, e.g. through LD_LIBRARY_PATH)           */
/*                                                                       */
/* This file is under the GNU Library General Public License version 2,  */
/* the licence of Rexx/SQL (see LICENSE in the rexxsql folder).          */

Parse Arg db
If db == "" Then db = "rexxsql-smoke.db"
Call SysFileDelete db

failures = 0

Call RxFuncAdd "SQLLoadFuncs", "rexxsql", "SQLLoadFuncs"
Call Check "SQLLoadFuncs", SQLLoadFuncs(), "0"

version = SQLVariable("VERSION")
Say "Rexx/SQL:" version
Call Check "VERSION mentions SQLite3", Word(version, Words(version)), "SQLite3"

Call Check "SQLConnect",  SQLConnect("c1", , , db), "0"
Call Check "create",      SQLCommand("s1", "create table t (id integer, name varchar(20))"), "0"
Call Check "insert 1",    SQLCommand("s2", "insert into t values (1, 'one')"), "0"
Call Check "insert 2",    SQLCommand("s3", "insert into t values (2, 'two')"), "0"
Call Check "select",      SQLCommand("q1", "select id, name from t order by id"), "0"
Call Check "row count",   q1.id.0, "2"
Call Check "row 1 id",    q1.id.1, "1"
Call Check "row 1 name",  q1.name.1, "one"
Call Check "row 2 id",    q1.id.2, "2"
Call Check "row 2 name",  q1.name.2, "two"
Call Check "SQLDisconnect", SQLDisconnect(), "0"
Call Check "SQLDropFuncs",  SQLDropFuncs(), "0"

Call SysFileDelete db

If failures == 0 Then Say "OK: all checks passed"
Else Say "FAILED:" failures "check(s)"
Exit failures \== 0

Check: Procedure Expose failures sqlca.
  Use Arg what, got, expected
  If got == expected Then Return
  failures = failures + 1
  Say "FAIL:" what": got '"got"', expected '"expected"'"
  If Symbol("SQLCA.SQLERRM") == "VAR" Then Say "      SQLCA.SQLERRM:" sqlca.sqlerrm
  Return
