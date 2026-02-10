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

  let(:root) { build_trie(%w[cat car cart dog]) }

  it 'supports word membership checks' do
    expect(root.include?('cat')).to be(true)
  end

  it 'returns false for missing words' do
    expect(root.include?('cap')).to be(false)
  end

  it 'supports prefix checks' do
    expect(root.prefix?('ca')).to be(true)
  end

  it 'supports prefix-based word listing' do
    expect(root.words_with_prefix('ca').sort).to eq(%w[car cart cat])
  end

  it 'supports delete for common mutation flows' do
    root.delete('cart')
    expect(root.include?('cart')).to be(false)
  end

  it 'keeps unrelated words after delete' do
    root.delete('cart')
    expect(root.include?('car')).to be(true)
  end

  it 'supports shovel insertion shorthand' do
    trie = described_class.new('')
    trie << 'cat'
    expect(trie.include?('cat')).to be(true)
  end
end
