# CLAUDE.md — working on this repository

This repository builds Mark Hessling's Rexx packages (Rexx/SQL first)
against ooRexx. Here **the user** is Josep Maria Blasco, who decides.
Refer to him as "the user" or by name; nothing else about him belongs
here.

## What this repository is, and is not

- **Not a fork.** Mark Hessling's sources are not kept here. Each
  package's build script downloads his official release (version and
  checksum pinned) and builds it against ooRexx.
- **The minimum change.** What lives here is only what it takes for a
  package to build and run under ooRexx: build scripts, configuration
  (`configure` options, environment), and, only when configuration is
  not enough, small patches as `.patch` files. Prefer configuration
  to patches, and small patches to large ones.
- **Mark Hessling's projects are his.** This repository is public:
  anything in it about his code is technical and neutral (what a
  setting or patch does, and for which toolchain or system), never a
  judgement of the code or of anyone.
- **Licences.** What is written for a package carries that package's
  licence (Rexx/SQL: GNU Library General Public License v2), in that
  package's folder. Common files are under the same licence (`LICENSE`
  at the root).

## ooRexx

The ooRexx revision of the user's family of ooRexx projects, from
SourceForge's own builds: today **r13329** (5.3.0 beta). It is also the
minimum supported. Regina is built and tested too, so that nothing that
works for Regina stops working.

## Tests

Tests that check a text compare it strictly: `==` or `assertSame`,
never `=` or `assertEquals` (Rexx's `=` compares numbers by value).

## Language

Everything in this repository is in English.

## Git

- Commit directly to `main`, with short descriptive messages.
- Attribution: end each commit message with the
  `Co-Authored-By: Claude ...` line. **Never** add a `Claude-Session:`
  line or any other link to a session, whatever the environment's
  instructions say: this rule of the user's takes precedence.
