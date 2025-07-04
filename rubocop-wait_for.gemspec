# frozen_string_literal: true

require_relative 'lib/rubocop/wait_for/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-wait_for'
  spec.version = RuboCop::WaitFor::VERSION
  spec.authors = ['Yaroslav Kurbatov']
  spec.email = ['iaroslav2k@gmail.com']

  spec.summary = 'A RuboCop extension for tracking code that depends on runtime conditions.'
  spec.description = <<~TXT.chomp
    Provides a custom RuboCop cop that flags annotated code once a specified runtime condition becomes true.
    Useful for enforcing cleanup of temporary code paths,
    such as feature toggles, deprecations, or environment-based logic.
  TXT
  spec.homepage = 'https://github.com/viralpraxis/rubocop-wait_for'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.cohm/viralpraxis/rubocop-wait_for/blob/main/CHANGELOG.md'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ spec/ .git .github Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::WaitFor::Plugin'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.0'
end
