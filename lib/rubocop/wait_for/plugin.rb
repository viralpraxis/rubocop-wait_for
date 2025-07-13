# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module WaitFor
    # A plugin that integrates rubocop-wait_for with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-wait_for',
          version: VERSION,
          homepage: 'https://github.com/viralpraxis/rubocop-wait_for',
          description: 'A RuboCop extension for tracking code that depends on runtime conditions.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
