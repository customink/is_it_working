# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2019-09-20

### Added

- Checks can be set to a `warn` status when non-critical errors occur.
- Timeouts can be set to add a `warn` or `fail` status to a check's messages when execution runs
  past a set threshold.

### Changed

- `Handler#check` signature now takes optional params for `timeout` and `warn_timeout`.
- The handler will report an `HTTP 203` status when a run is successful but there are warnings.

## [1.1.0] - 2019-09-13

### Changed

- Forked from [tribune/is_it_working](https://github.com/tribune/is_it_working).
