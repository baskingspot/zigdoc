const std = @import("std");
const ziglint = @import("ziglint");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // `-Dstrip`: no debug info, as the release workflow ships it. It also makes
    // the Mach-O build reproducible: the debug map carries each object file's
    // mtime, and the linker writes it into the binary.
    const strip = b.option(bool, "strip", "Omit debug info (the release build)");

    const exe = b.addExecutable(.{
        .name = "zigdoc",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = strip,
        }),
    });

    b.installArtifact(exe);

    // Keep the command reference explicit so installs only install the binary.
    const reference_run = b.addRunArtifact(exe);
    reference_run.addArg("--help");
    const help_output = reference_run.captureStdOut(.{});

    const gen_reference = b.addExecutable(.{
        .name = "gen_reference",
        .root_module = b.createModule(.{
            .root_source_file = b.path("build_reference.zig"),
            .target = target,
            .optimize = .ReleaseFast,
        }),
    });

    const run_gen = b.addRunArtifact(gen_reference);
    run_gen.addFileArg(help_output);
    const reference_file = run_gen.addOutputFileArg("reference.md");

    const update_reference = b.addUpdateSourceFiles();
    update_reference.addCopyFileToSource(reference_file, "docs/content/reference.md");

    const reference_step = b.step("reference", "Regenerate docs/content/reference.md, the command reference page");
    reference_step.dependOn(&update_reference.step);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);

    const fmt_step = b.step("fmt", "Check code formatting");
    const fmt_check = b.addFmt(.{
        .paths = &.{ "src", "build.zig", "build.zig.zon", "build_reference.zig" },
        .check = true,
    });
    fmt_step.dependOn(&fmt_check.step);
    test_step.dependOn(fmt_step);

    const lint_step = b.step("lint", "Run ziglint");
    const ziglint_dep = b.dependency("ziglint", .{ .optimize = .ReleaseFast });
    lint_step.dependOn(ziglint.addLint(
        b,
        ziglint_dep,
        &.{ b.path("src"), b.path("build.zig"), b.path("build_reference.zig") },
    ));
    test_step.dependOn(lint_step);
}
