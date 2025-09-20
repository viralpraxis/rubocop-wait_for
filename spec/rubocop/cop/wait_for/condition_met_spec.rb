# frozen_string_literal: true

require 'time'

RSpec.describe RuboCop::Cop::WaitFor::ConditionMet, :config do
  before do
    stub_const('RUBY_VERSION', '3.4')
    allow(Kernel).to receive(:warn)
  end

  %w[wait-for rubocop:wait-for rubocop-wait-for].each do |directive|
    context "with `#{directive}` directive" do
      it 'registers an offense when condition holds' do
        expect_offense(<<~RUBY, directive: directive)
          # %{directive} RUBY_VERSION >= '3.2.'
          ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
        RUBY
      end

      it 'registers an offense condition holds with extra spaces before an condition' do
        expect_offense(<<~RUBY, directive: directive)
          # %{directive}   RUBY_VERSION >= '3.2.'
          ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
        RUBY
      end

      it 'registers an offense condition holds with extra spaces after an condition' do
        expect_offense(<<~RUBY, directive: directive)
          # %{directive} RUBY_VERSION >= '3.2.'#{'   '}
          ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
        RUBY
      end

      it 'does not register an offense when condition does not hold' do
        expect_no_offenses(<<~RUBY)
          # #{directive} RUBY_VERSION < '3.3.'
        RUBY
      end

      it 'does not register an offense without an conditiong' do
        expect_no_offenses(<<~RUBY)
          # #{directive}
        RUBY
      end

      it 'does not register an offense with syntax error' do
        expect_no_offenses(<<~RUBY)
          # #{directive} 1.1.1
        RUBY

        expect(Kernel).to have_received(:warn)
          .with(/RuboCop::Cop::WaitFor::ConditionMet: Encountered exception during evaluating condition/)
          .once
      end

      context 'with gem version condition' do
        before do
          allow(config).to receive(:gem_versions_in_target)
            .and_return({ 'rails' => Gem::Version.new('3.4') })
        end

        it 'registers an offense when condition holds' do
          expect_offense(<<~RUBY, directive: directive)
            # %{directive} gem-version rails '>= 3.2'
            ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
          RUBY
        end

        it 'does not register an offense when condition does not hold' do
          expect_no_offenses(<<~RUBY)
            # %{directive} gem-version rails '>= 3.5'
          RUBY
        end

        it 'registers an offense when complex condition holds' do
          expect_offense(<<~RUBY, directive: directive)
            # %{directive} gem-version rails '>= 3.2' '< 3.6'
            ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
          RUBY
        end

        it 'does not register an offense when complex condition does not hold' do
          expect_no_offenses(<<~RUBY)
            # %{directive} gem-version rails '>= 3.0' '< 3.4'
          RUBY
        end
      end

      context 'with Ruby version condition' do
        before do
          allow(config).to receive(:target_ruby_version)
            .and_return(Gem::Version.new('3.4.5'))
        end

        it 'registers an offense when condition holds' do
          expect_offense(<<~RUBY, directive: directive)
            # %{directive} ruby-version '>= 3.4'
            ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
          RUBY
        end

        it 'registers an offense when condition using only major version holds' do
          expect_offense(<<~RUBY, directive: directive)
            # %{directive} ruby-version '>= 3'
            ^^^{directive}^^^^^^^^^^^^^^^^^^^^ Condition has been met.
          RUBY
        end

        it 'does not register an offense when condition does not hold' do
          expect_no_offenses(<<~RUBY)
            # %{directive} ruby-version '>= 3.5'
          RUBY
        end

        it 'registers an offense when complex condition holds' do
          expect_offense(<<~RUBY, directive: directive)
            # %{directive} ruby-version '>= 3.4' '< 3.6'
            ^^^{directive}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Condition has been met.
          RUBY
        end

        it 'does not register an offense when complex condition does not hold' do
          expect_no_offenses(<<~RUBY)
            # %{directive} ruby-version '>= 3.5' '< 3.6'
          RUBY
        end
      end
    end
  end

  describe '#external_dependency_checksum' do
    subject(:checksum) { described_class.new.external_dependency_checksum }

    before { allow(Time).to receive(:now).and_return(Time.parse('2025-07-04 22:02:53.141065464 +0400')) }

    around do |example|
      initial_value = ENV.fetch('RUBOCOP_WAIT_FOR_CHECK_ALL', nil)
      ENV['RUBOCOP_WAIT_FOR_CHECK_ALL'] = variable_value

      example.run
    ensure
      ENV['RUBOCOP_WAIT_FOR_CHECK_ALL'] = initial_value
    end

    context 'when `RUBOCOP_WAIT_FOR_CHECK_ALL` is set to `"1"`' do
      let(:variable_value) { '1' }

      it { expect(checksum).to eq(Time.now.to_i.to_s) }
    end

    context 'when `RUBOCOP_WAIT_FOR_CHECK_ALL` is set to `"0"`' do
      let(:variable_value) { '0' }

      it { expect(checksum).to be_nil }
    end

    context 'when `RUBOCOP_WAIT_FOR_CHECK_ALL` is not set to `"0"`' do
      let(:variable_value) { '0' }

      before { ENV.delete('RUBOCOP_WAIT_FOR_CHECK_ALL') }

      it { expect(checksum).to be_nil }
    end
  end
end
