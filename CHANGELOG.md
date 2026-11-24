# Changelog

Changes a user of zigdoc notices, newest first, in the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) form.

## [Unreleased]

## [0.6.0] - 2026-11-24

zigdoc moves to the baskingspot org, and the releases with it: a zip for Windows, a Homebrew cask, and an attestation on every archive. The command works as it did, apart from one module lookup fix.

### Added

- A zip for `windows-x64`, beside the tarballs for `linux-x64`, `linux-arm64`, and `macos-arm64`.
- A Homebrew cask, `brew install --cask baskingspot/tap/zigdoc`. The release installs it on macOS and on Linux before it reaches the tap.
- A `SHA256SUMS` file and a sigstore attestation on every release, so `gh attestation verify` names the workflow that built a download.

### Changed

- zigdoc lives at `baskingspot/zigdoc`. The install commands and the releases move with it, and the old GitHub URLs redirect.
- A module whose root source file a build step generates now resolves. zigdoc runs the step that produces the file before it reads the module.
- `zigdoc @init` writes a longer `AGENTS.md`, with design priorities, naming, ownership, and file-size rules, and a `build.zig` whose test step runs ziglint.
