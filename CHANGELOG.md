# Changelog

## [0.4.0 UNRELEASED]

### Added
- Dynamic host volume #58

### Changed
- Removed `failed_when` in `01-create_vault_policy_to_read_secrets.yml` & updated README [no issue]

## [0.3.0]

### Added
- Added canary deployment and switch #64
- Added intentions sections to README.md #65
- Added input variable and template stanza for Consul Connect upstreams #72
- Added input variable for MC extra commands, appended to command in MC job #73
- Added user defined variables for resources #70
- Added output for minio port number #77

### Changed
- Proper rendering of credentials #66
- Removed box example [no issue]
- Updated to fit hashistack v0.7.1 #71

## [0.2.0]

### Added
- Github templates for issues and PRs #54

### Changed
- Updated up and template_example targets in makefile #48
- Updated enforce-changelog in github workflow file #50
- Synced with template and updated box version #52
- Changed path for data_dir local/data -> minio/data #57

## [0.1.0]

### Added
- Use vault to generate secrets for minio using kv #16
- Code to support successful execution of nomad mc job and tests when consul_acl_default_policy is deny #26
- Updated README.md #21
- Added host volume for minio #20
- Added tests to verify host volume for minio #34
- Added release and release-prerequisites jobs in workflow file #35
- Added github action to create follow up issue after github release #36
- Added changelog enforcer #42
- Added switch use_host_volume for enabling/disabling host volume #39
- Use ansible module to create random strings #44

### Changed
- terraform-provider-nomad 1.4.0 -> 1.4.9 and vault provider 2.13.0 -> 2.14.0 #30

## [0.0.3]

### Added
- Tests #4
- Documentation #3
- File/directories upload examples #11

## [0.0.2]

### Changed
- Sync origin template #10
- Rename vars in variables.tf

### Added
- Initial example
- Changelog #7

### Fixed
- Remove hardcoded nomad provider #6

## [0.0.1]

### Added
- Initial draft
