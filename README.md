# RuboCop WaitFor

## Installation

Just install the `rubocop-wait_for` gem

```bash
gem install rubocop-wait_for
```

or if you use bundler put this in your `Gemfile`

```ruby
gem 'rubocop-wait_for', require: false
```

## Usage

You need to tell RuboCop to load the WaitFor extension. There are two
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
plugins:
  - rubocop-other-extension
  - rubocop-wait_for
```

Now you can run `rubocop` and it will automatically load the RuboCop WaitFor
cops together with the standard cops.

> [!NOTE]
> The plugin system is supported in RuboCop 1.72+. In earlier versions, use `require` instead of `plugins`.

### Command line

```bash
rubocop --plugin rubocop-wait_for
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.plugins << 'rubocop-wait_for'
end
```

## Purpose

`rubocop-wait_for` introduces the `WaitFor/ConditionMet` cop, which scans source comments for wait-for directives:

```ruby
# wait-for Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4.0')
some_code_to_remove_once_ruby34_is_in_use()
```

> [!NOTE]
>
> Use can use an alias `# rubocop-wait-for <code>`

If the condition inside the comment evaluates to `true` at the time of linting, RuboCop registers an offense.

This enables workflows like:

- Automatically flagging feature-flagged code once the feature is launched.

- Alerting when temporary code should be deleted (e.g. after a given date or version).

- Monitoring environment-specific conditions in CI pipelines.

> [!WARNING]
> All the code found after the directive is passed directly to `Kernel.eval`. Use with caution.

Another situation this cop might be useful in is checking gem version.

You can achieve it by using a special form of the magic comment:

```ruby
# wait-for gem-version rails '>= 8.1'
```

This condition evaluates to `true` when the detected Rails version is at least `8.1`.

Note that gem versions are determined statically using RuboCop’s [built-in feature](https://docs.rubocop.org/rubocop/development.html#limit-by-ruby-or-gem-versions).

You can also use multiple version requirements:

```ruby
# wait-for gem-version rails '>= 8.1' '< 8.4'
```

### Caveats

1. Missing dependencies

   RuboCop does not automatically load project dependencies from your `Gemfile.lock`. If your condition relies on gems like Rails, you may need to require them manually:

   ```ruby
   # wait-for require 'rails'; defined?(::Rails.some_new_feature) != nil
   some_code_to_remove_once_new_rails_feature_is_available()
   ```

2. Caching

   Since `rubocop-wait_for` depends on RuboCop’s caching mechanism, offenses might not be reported until the cache is invalidated — for instance for dynamic conditions like time-based checks.

   You can force cache invalidation by passing `RUBOCOP_WAIT_FOR_CHECK_ALL=1` environment variable:

   ```shell
   RUBOCOP_WAIT_FOR_CHECK_ALL=1 bundle exec rubocop --only WaitFor/ConditionMet
   ```

## License

`rubocop-wait_for` is MIT licensed. [See the accompanying file](LICENSE) for
the full text.
