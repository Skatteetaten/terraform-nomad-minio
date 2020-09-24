# Changelog

## [0.0.1 UNRELEASED]


### Changed

- updated documentation: consul namespaces #28
- trigger tests for template_example by condition #12
- updated the make clean in makefile to remove more tmp files/folders #8

### Added

- Added command that formats/prettify all `.tf`-files in directory #21 (overwritten by #24)
- Added check for consul and terraform binary in the `Makefile` #20
- Added `make pre-commit` command that use local linter and formatts/prettyfies all `.tf` files #24
- `Vault PKI` section to README

### Fixed

- links in documentation #5
