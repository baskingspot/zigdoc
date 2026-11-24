+++
title = "zigdoc"
+++

A command-line tool to view documentation for Zig standard library symbols.

The doc comments in the Zig standard library are the manual, and they are spread
over hundreds of files. `zigdoc std.mem.Allocator` prints the comment, the file
and line, the signature, and the members, without leaving the terminal. With a
`build.zig` in the current directory it reads the modules that build declares,
so a dependency is documented the same way.

- [Symbols](#symbols): one symbol at a time, with its doc comment, signature, and members. `zigdoc std.mem.Allocator` prints all four.
- [Modules from your build](#modules-from-your-build): `zigdoc vaxis.Window` reads the modules that your `build.zig` declares, and `--dump-imports` prints them as JSON.
- [Starting a project](#starting-a-project): `zigdoc @init` writes a Zig 0.16 project with an `AGENTS.md` that tells a coding agent how to work in it.
- [Limits](#limits): one standard library, the modules the build declares, and no quiet run.

The [command reference](reference/) lists every option and command, as
`zigdoc --help` prints them.

# Getting started

## Install

zigdoc runs `zig` to find the standard library, so `zig` must be on `PATH`. It
reads projects on Zig 0.14, 0.15, and 0.16, and stops with
`error.UnsupportedZigVersion` on any other version.

With Homebrew, on macOS or Linux:

```sh
brew install --cask baskingspot/tap/zigdoc
```

With mise:

```sh
mise use -g github:baskingspot/zigdoc
```

With Nix:

```sh
nix run github:baskingspot/zigdoc/v0.6.0 -- std.ArrayList
```

Each [release](https://github.com/baskingspot/zigdoc/releases) has a tarball for
`linux-x64`, `linux-arm64`, and `macos-arm64`, a zip for `windows-x64`, and a
`SHA256SUMS` file. The archives are attested, so check a download with:

```sh
gh attestation verify FILE -R baskingspot/zigdoc --signer-repo baskingspot/gh-actions
```

From source:

```sh
zig build install -Doptimize=ReleaseFast --prefix $HOME/.local
```

## Ask about a symbol

```sh
zigdoc std.ArrayList
```

```text
Symbol: std.ArrayList
Location: /nix/store/…/lib/zig/std/std.zig:49
Category: type_function
Signature: pub fn ArrayList(comptime T: type) type

Documentation:
  A contiguous, growable list of items in memory. This is a wrapper around a
  slice of `T` values.
```

The `Location` is the file and line that declares the symbol, so the next stop
is the source. A deprecated symbol carries the note in its doc comment, as
`std.fs.path` does. An alias names its target.

## Ask about a module

Run zigdoc from the directory that holds the `build.zig` of the project you are
reading:

```sh
zigdoc vaxis.Window
```

The first name is the module that `build.zig` declares, and it resolves the same
way the compiler resolves it. A module whose root file a build step generates
works too: zigdoc runs the step before it reads the module.

# Symbols

A symbol is written the way Zig writes it, with dots between the parts, and no
leading `@`:

```sh
zigdoc std.ArrayList
zigdoc std.mem.Allocator
zigdoc std.http.Server
```

The output has the doc comment, the signature of a function or the fields of a
type, and its public members. An alias follows the target, so
`zigdoc std.mem.Allocator` shows both the alias and the file that defines it.

# Modules from your build

zigdoc reads `build.zig` in the current directory and the modules it declares.
It executes the build graph with one of the build runners it embeds, so the
answer matches what `zig build` would compile. The runner is written to
`.zig-cache/zigdoc_build_runner.zig`.

`--dump-imports` prints the same table as JSON, which is what an editor
integration wants:

```sh
zigdoc --dump-imports
```

```json
{
  "modules": {
    "mylib": {
      "root": "/home/you/project/src/lib.zig"
    }
  }
}
```

No `build.zig` is an error only for a module name. A standard library symbol
works anywhere.

# Starting a project

`zigdoc @init` writes a Zig 0.16 project in the current directory: `build.zig`,
`build.zig.zon`, `src/main.zig`, `.gitignore`, and an `AGENTS.md` that states
the project's conventions, its lint step, and how to look up an API with zigdoc.

```sh
mkdir my-project && cd my-project
zigdoc @init
```

The `AGENTS.md` is a contract for a coding agent: naming, ownership,
verification, and file layout. Edit it, since it is the file the agent reads
first. The `build.zig` that `@init` writes runs ziglint with `zig build test`.

# Limits

- zigdoc reads the standard library of the `zig` on `PATH`. `ZIG_LIB_DIR` points it at another lib directory, and no flag does.
- Only the public declarations that the walk reaches are documented. A file that nothing imports is not in the table.
- A module that `build.zig` does not declare is invisible, even when a source file imports it. `zigdoc --dump-imports` lists what zigdoc sees.
- `zigdoc @init` writes a Zig 0.16 project. A project on another version is written by hand.
- Windows is a shipped target, not a tested shell. The build runner has not been run there.
- The import trace goes to stderr on every run, which is noise next to the answer you asked for. Issue #7 tracks it.
