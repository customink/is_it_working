# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2020-02-04

### Added

- Handler now exposes a `reporter` method to log or track time series statistics of check performance

## [1.2.1] - 2020-02-01

### Fixed

- There is no `hostname` on Lambda.

## [1.2.0] - 2019-11-15

### Added

- Checks can be set to a `warn` status when non-critical errors occur.
- Handler now exposes a `timer` method which can wrap a check and ok/warn/fail it based on how long it takes

### Changed

- The handler will report an `HTTP 302` status when a run is successful but there are warnings.

## [1.1.0] - 2019-09-13

### Changed

- Forked from [tribune/is_it_working](https://github.com/tribune/is_it_working).
