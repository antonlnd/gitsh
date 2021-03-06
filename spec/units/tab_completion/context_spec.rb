require 'spec_helper'
require 'gitsh/tab_completion/context'

describe Gitsh::TabCompletion::Context do
  describe '#prior_words' do
    it 'produces the words in the input before the word being completed' do
      context = described_class.new('stash drop my-')
      expect(context.prior_words).to eq %w(stash drop)
    end

    it 'only considers the current command' do
      context = described_class.new('stash apply my-stash && stash drop my-')
      expect(context.prior_words).to eq %w(stash drop)
    end

    it 'handles multiple lines' do
      context = described_class.new("(add .\ncommit -")
      expect(context.prior_words).to eq %w(commit)
    end

    it 'handles partially quoted words' do
      context = described_class.new('sta"sh" drop my-')
      expect(context.prior_words).to eq %w(stash drop)
    end

    it 'only considers the current subshell' do
      context = described_class.new(':echo $(config ')
      expect(context.prior_words).to eq %w(config)
    end

    it 'only considers the current parenthetical' do
      context = described_class.new('(config ')
      expect(context.prior_words).to eq %w(config)
    end

    context 'with input the Lexer cannot handle' do
      it 'does not explode' do
        allow(Gitsh::Lexer).
          to receive(:lex).and_raise(RLTK::LexingError.new(0, 1, 0, nil))

        expect(described_class.new('bad input').prior_words).to eq []
      end
    end
  end
end
