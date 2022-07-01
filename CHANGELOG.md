# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2022-07-01
### Added
- Support for Ruby 2.1
- Support for Ruby 2.2
- Support for Ruby 2.3
- Support for Ruby 2.4
- Support for Ruby 2.5
- Support for Ruby 2.6
- Support for Ruby 2.7
- Support for Ruby 3.0
- Support for Ruby 3.1

## [1.3.1] - 2022-02-25

### Fixed

- There is no `hostname` on Lambda. Use return status of `which hostname` before calling `hostname`.
- Enforce string type on `hostname=` method using `to_s`
- Change length-check on `@hostname` to use Ruby `empty?` predicate method

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
