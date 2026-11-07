# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- `SdMon.sdmon_path/0`
- Typespecs and documentation for `SdMon`
- Usage and requirements sections in README
- Hex package metadata (description, license, links) and ExDoc config
### Changed
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


## [0.1.0] - 2022-07-27
### Added
- Initial release

[Unreleased]: https://github.com/udoschneider/sdmon_ex/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/udoschneider/sdmon_ex/releases/tag/v0.1.0
