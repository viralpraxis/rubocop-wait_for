# frozen_string_literal: true

RSpec.describe RuboCop::WaitFor::Plugin do
  subject(:plugin) { described_class.new }

  describe '#about' do
    subject(:about) { plugin.about }

    it 'has expected version' do
      expect(about.version).to eq(RuboCop::WaitFor::VERSION)
    end
  end

  it { is_expected.not_to be_nil }

  describe '#supported?' do
    it 'supports `rubocop` engine' do
      expect(plugin.supported?(LintRoller::Context.new(engine: :rubocop))).to be(true)
    end

    it 'does not support unrelated engine' do
      expect(plugin.supported?(LintRoller::Context.new(engine: :foobar))).to be(false)
    end
  end
end
