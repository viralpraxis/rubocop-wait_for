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
        DIRECTIVE_PATTERN = /#\s*(?:rubocop[:-])?wait-for\s+(.+)/.freeze
        private_constant(*constants(false))

        MSG = 'Condition has been met.'

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

        def evaluate_condition(condition) # rubocop:disable Metrics/MethodLength
          if (gem_condition = gem_version_condition(condition))
            gem_version_requirement_met?(gem_condition)
          elsif (ruby_condition = ruby_version_condition(condition))
            ruby_version_requirement_met?(ruby_condition)
          else
            begin
              Kernel.eval(condition) # rubocop:disable Security/Eval
            rescue Exception => e # rubocop:disable Lint/RescueException
              Kernel.warn "#{self.class.name}: Encountered exception during evaluating condition: #{e.message}"

              false
            end
          end
        end

        def gem_version_condition(condition)
          unless (match_data = /\Agem-version\s+([a-zA-Z0-9_-]+)\s+((?:['"][^'"]+['"]\s*)+)\z/i.match(condition.strip))
            return
          end

          {
            gem_name: match_data[1],
            requirements: Gem::Requirement.new(match_data[2].scan(/['"]([^'"]+)['"]/).flatten)
          }
        end

        def gem_version_requirement_met?(gem_version_requirement)
          all_gem_versions_in_target = @config.gem_versions_in_target
          return false unless all_gem_versions_in_target

          gem_version_in_target = all_gem_versions_in_target[gem_version_requirement.fetch(:gem_name)]
          return false unless gem_version_in_target

          gem_version_requirement.fetch(:requirements).satisfied_by?(gem_version_in_target)
        end

        def ruby_version_condition(condition)
          unless (match_data = /\Aruby-version\s+((?:['"][^'"]+['"]\s*)+)\z/i.match(condition.strip))
            return
          end

          {
            requirements: Gem::Requirement.new(
              match_data[1].scan(/['"]([^'"]+)['"]/).flatten
            )
          }
        end

        def ruby_version_requirement_met?(ruby_version_requirement)
          ruby_version_requirement
            .fetch(:requirements)
            .satisfied_by?(Gem::Version.new(RUBY_VERSION))
        end
      end
    end
  end
end
