const std = @import("std");

// Writes docs/content/reference.md, the command reference page of the guide,
// from the `zigdoc --help` text. The page is generated so the site's list of
// options and commands cannot drift from the program's.

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

    const reference = try std.fmt.allocPrint(allocator,
        \\+++
        \\title = "Command reference"
        \\template = "page.html"
        \\+++
        \\
        \\# Command reference
        \\
        \\Every option and command, as `zigdoc --help` prints them.
        \\
        \\```text
        \\{s}```
        \\
        \\Back to [the guide](../).
        \\
    , .{help_content});
    defer allocator.free(reference);

    try std.Io.Dir.cwd().writeFile(init.io, .{ .sub_path = output_file, .data = reference });
}
