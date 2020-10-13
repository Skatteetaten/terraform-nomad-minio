# Changelog

## [1.0.0 UNRELEASED]


### Changed

- updated documentation: consul namespaces #28
- trigger tests for template_example by condition #12
- updated the make clean in makefile to remove more tmp files/folders #8
- updated up and template_example targets in makefile to use ci_test instead of local_test variable #38
- updated Makefile `pre-commit` with `check_for_terraform_binary` #41
- updated up and template_example targets in makefile #45
- bumped vagrant-hashistack version to 0.5 #50

### Added

- Added command that formats/prettify all `.tf`-files in directory #21 (overwritten by #24)
- Added check for consul and terraform binary in the `Makefile` #20
- Added `make pre-commit` command that use local linter and formatts/prettyfies all `.tf` files #24
- `Vault PKI` section to README
- Token for terraform-provider-vault #35
- Section how to sync modules with the latest template #32
- Added changelog enforcer to pipeline checks #31

### Fixed

- links in documentation #5
