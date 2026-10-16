const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args.len != 3) {
        std.debug.print("Usage: {s} <help-file> <output-file>\n", .{args[0]});
        return error.InvalidArgs;
    }

    const help_file = args[1];
    const output_file = args[2];

    const help_content = try std.Io.Dir.cwd().readFileAlloc(init.io, help_file, allocator, .limited(1024 * 1024));
    defer allocator.free(help_content);

    const readme = try std.fmt.allocPrint(allocator,
        \\<h1>
        \\  <picture>
        \\    <source media="(prefers-color-scheme: dark)" srcset="docs/static/logo-dark.svg">
        \\    <img src="docs/static/logo.svg" alt="zigdoc" height="48">
        \\  </picture>
        \\</h1>
        \\
        \\A command-line tool to view documentation for Zig standard library symbols.
        \\
        \\## Installation
        \\
        \\zigdoc runs `zig` to find the standard library, so `zig` must be on your `PATH`.
        \\
        \\With mise:
        \\
        \\```bash
        \\mise use -g github:baskingspot/zigdoc
        \\```
        \\
        \\With Nix:
        \\
        \\```bash
        \\nix run github:baskingspot/zigdoc -- std.ArrayList
        \\```
        \\
        \\From a release: each [release](https://github.com/baskingspot/zigdoc/releases) has tarballs for
        \\Linux on x86_64 and aarch64 and for macOS on aarch64, with a `SHA256SUMS` file. Check a download
        \\with `gh attestation verify <file> -R baskingspot/zigdoc`.
        \\
        \\From source:
        \\
        \\```bash
        \\zig build install -Doptimize=ReleaseFast --prefix $HOME/.local
        \\```
        \\
        \\## Usage
        \\
        \\```
        \\{s}```
        \\
        \\## Project Initialization
        \\
        \\`zigdoc @init` scaffolds a minimal Zig 0.16 project with `AGENTS.md`,
        \\`build.zig`, and `build.zig.zon`.
        \\
        \\```bash
        \\mkdir my-project && cd my-project
        \\zigdoc @init
        \\```
        \\
        \\## Examples
        \\
        \\```bash
        \\# Standard library symbols
        \\zigdoc std.ArrayList
        \\zigdoc std.mem.Allocator
        \\zigdoc std.http.Server
        \\
        \\# Imported modules from build.zig
        \\zigdoc zeit.timezone.Posix
        \\```
        \\
        \\## Features
        \\
        \\- View documentation for any public symbol in the Zig standard library
        \\- Access documentation for imported modules from your build.zig
        \\- Shows symbol location, category, and signature
        \\- Displays doc comments and members
        \\- Follows aliases to implementation
        \\
        \\## Work on it
        \\
        \\`nix develop` provides the toolchain, and `just ci` runs what CI runs. `README.md` is generated:
        \\change `build_readme.zig`, then run `zig build readme`.
        \\
        \\## License
        \\
        \\MIT. See `LICENSE`. The logo files in `docs/static/` are baskingspot marks and are not covered
        \\by it. See `docs/static/LICENSE`.
        \\
        \\<a href="https://github.com/baskingspot"><img
        \\src="https://raw.githubusercontent.com/baskingspot/.github/main/brand/assets/badge.svg"
        \\alt="baskingspot" height="24"></a>
        \\
    , .{help_content});
    defer allocator.free(readme);

    try std.Io.Dir.cwd().writeFile(init.io, .{ .sub_path = output_file, .data = readme });
}
