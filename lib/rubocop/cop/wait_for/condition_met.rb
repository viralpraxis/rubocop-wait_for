# frozen_string_literal: true

module RuboCop
  module Cop
    module WaitFor
      # Evaluates annotated comments that specify a runtime condition and
      # registers an offense once the condition evaluates to true.
      #
      # It is designed to support use cases such as removing temporary code once a
      # feature flag is enabled, a deprecation deadline is reached, or some
      # environment-dependent behavior becomes active.
      #
      # @example
      #   # bad
      #   # Assuming RUBY_VERSION is '3.4.4'
      #   # wait-for Gem::Version.new(RUBY_VERSION) >= '3.4.0'
      #   some_code_to_update_upon_upgrading_to_ruby34
      #
      #   # good
      #   # Assuming RUBY_VERSION is '3.3.8'
      #   # wait-for Gem::Version.new(RUBY_VERSION) >= '3.4.0'
      #   some_code_to_update_upon_upgrading_to_ruby34
      class ConditionMet < Base
        DIRECTIVE_PATTERN = /#\s*(?:rubocop[:\-])?wait-for\s+(.+)/.freeze
        private_constant(*constants(false))

        MSG = 'condition has been met.'

        def external_dependency_checksum
          Time.now.to_i.to_s if ENV['RUBOCOP_WAIT_FOR_CHECK_ALL'] == '1'
        end

        def on_new_investigation
          return if processed_source.buffer.source.empty?

          processed_source.comments.each do |comment|
            next unless (condition = DIRECTIVE_PATTERN.match(comment.text))

            result = evaluate_condition(condition.captures[0])

            add_offense(comment) if result == true
          end
        end

        private

        def evaluate_condition(condition)
          Kernel.eval(condition) # rubocop:disable Security/Eval
        rescue Exception => e # rubocop:disable Lint/RescueException
          Kernel.warn "#{self.class.name}: Encountered exception during evaluating condition: #{e.message}"

          false
        end
      end
    end
  end
end
