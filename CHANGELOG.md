## [Unreleased]

- Add support for `# wait-for ruby-version <version-specification>` syntax to check `TargetRubyVersion` statically.
- Fix an error when a `gem-version` or `ruby-version` directive contains a malformed requirement. Such directives now emit a warning instead.
- Fix `gem-version` directives not being reported after a gem upgrade until RuboCop's cache was invalidated.
- Fix directives quoted inside other comments, such as documentation examples, and inside `=begin`/`=end` blocks being evaluated.

## [0.2.1] - 2025:08-20

- Fix `config/default.yml` configuration. [#6](https://github.com/viralpraxis/rubocop-wait_for/pull/6)

## [0.2.0] - 2025-08-13

- Add support for statically evaluated gem version requirements. [#4](https://github.com/viralpraxis/rubocop-wait_for/pull/4)

## [0.1.0] - 2025-07-07

- Initial release.
