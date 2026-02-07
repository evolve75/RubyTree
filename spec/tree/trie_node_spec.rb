# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/trie'

RSpec.describe Tree::TrieNode do
  def build_trie(words)
    root = described_class.new('')
    words.each { |word| root.insert(word) }
    root
  end

  describe 'insert and include' do
    let(:root) { build_trie(%w[cat car cart]) }

    it 'finds an existing word' do
      expect(root.include?('cat')).to be(true)
    end

    it 'finds another existing word' do
      expect(root.include?('car')).to be(true)
    end

    it 'finds a longer existing word' do
      expect(root.include?('cart')).to be(true)
    end

    it 'returns false for a missing word' do
      expect(root.include?('cap')).to be(false)
    end
  end

  describe 'prefix' do
    let(:root) { build_trie(%w[cat car cart]) }

    it 'finds a shared prefix' do
      expect(root.prefix?('ca')).to be(true)
    end

    it 'finds a word as a prefix' do
      expect(root.prefix?('car')).to be(true)
    end

    it 'finds a full word prefix' do
      expect(root.prefix?('cart')).to be(true)
    end

    it 'returns false for a missing prefix' do
      expect(root.prefix?('dog')).to be(false)
    end
  end

  describe 'delete' do
    let(:root) { build_trie(%w[cat car cart]) }

    before { root.delete('cart') }

    it 'removes the deleted word' do
      expect(root.include?('cart')).to be(false)
    end

    it 'keeps other words' do
      expect(root.include?('car')).to be(true)
    end

    it 'returns true when deleting an existing word' do
      expect(root.delete('cat')).to be(true)
    end
  end

  describe 'words with prefix' do
    let(:root) { build_trie(%w[cat car cart dog]) }

    it 'returns all matches for a prefix' do
      expect(root.words_with_prefix('ca').sort).to eq(%w[car cart cat])
    end

    it 'returns the single match for a prefix' do
      expect(root.words_with_prefix('do')).to eq(%w[dog])
    end
  end
end
