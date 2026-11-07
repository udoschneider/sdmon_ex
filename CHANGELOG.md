# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- `SdMon.run/2` with `:method` and `:add_time` options
- Support for Longsys, Innodisk, ADATA, Transcend, Micron and Swissbit cards
  (via the sdmon update)
- `SdMon.sdmon_path/0`
- Typespecs and documentation for `SdMon`
- Usage and requirements sections in README
- Hex package metadata (description, license, links) and ExDoc config
### Changed
- Update bundled sdmon from v0.4.1 to upstream master `8a70aed` (newer than
  v0.9.0). Output is now produced by a JSON library; notable differences:
  `"error"` includes the OS error (e.g. `"device open failed (No such file or
  directory)"`), `"date"` no longer has a (wrong) `Z` suffix, and the new
  fields `"method"` and `"addTime"` are added; vendor flags such as
  `"SanDisk"` are booleans instead of the string `"true"`
- Update `elixir_make` from 0.6.3 to 0.10.1
- Require Elixir `~> 1.14` (needed by `elixir_make` 0.10)
- Rename CHANGELOG to CHANGELOG.md
- `SdMon.run/1` returns `{:error, {:invalid_json, output}}` instead of `:error`
  when the output cannot be decoded
### Fixed
- CHANGELOG version numbers
- `CHANGELOG.md` missing from the Hex package file list
- Empty `"version"` field in `sdmon` output
- `SdMon.run/1` raising when the `sdmon` binary cannot be executed; it now
  returns `{:error, {:exec_failed, reason}}`
- Placeholder test suite
- `make clean` leaving the empty `priv` directory behind
- sdmon rejecting valid card responses that contain no `0x00` byte (local
  patch to the bundled `sdmon.c`)
- Invalid JSON when card data contains control characters or non-UTF-8 bytes;
  such bytes are now decoded as `\u00XX`
- Hex package licenses now list the bundled GPL-2.0 / BSD-2-Clause code


## [0.1.0] - 2022-07-27
### Added
- Initial release

[Unreleased]: https://github.com/udoschneider/sdmon_ex/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/udoschneider/sdmon_ex/releases/tag/v0.1.0
