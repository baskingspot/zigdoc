# The zigdoc package. The Zig dependencies come from build.zig.zon.nix
# (`just zon2nix` regenerates it after a dependency bump), so the build needs
# no network.
{
  lib,
  stdenv,
  callPackage,
  zig_0_16,
}:
let
  # The version comes from build.zig.zon, which release-prep.py rewrites. If
  # that line ever stops matching, this evaluation fails instead of shipping a
  # stale version.
  version = lib.head (
    builtins.match ''[ ]*\.version = "([^"]+)".*'' (
      lib.findFirst (line: lib.hasInfix ".version = " line) "" (
        lib.splitString "\n" (builtins.readFile ../build.zig.zon)
      )
    )
  );
in
stdenv.mkDerivation {
  pname = "zigdoc";
  inherit version;
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../build.zig
      ../build.zig.zon
      ../build_readme.zig
      ../src
    ];
  };
  nativeBuildInputs = [ zig_0_16.hook ];
  zigBuildFlags = [
    "--system"
    "${callPackage ../build.zig.zon.nix { }}"
  ];
  meta = {
    description = "A command-line tool to view documentation for Zig standard library symbols";
    homepage = "https://github.com/baskingspot/zigdoc";
    license = lib.licenses.mit;
    mainProgram = "zigdoc";
    platforms = lib.platforms.unix;
  };
}
