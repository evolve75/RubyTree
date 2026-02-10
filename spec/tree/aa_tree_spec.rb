# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/aatree'

RSpec.describe Tree::AATree do
  def build_tree(entries)
    described_class.new(entries)
  end

  describe 'common key/value usage' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b'], [5, 'c']]) }

    it 'supports lookup by key' do
      expect(tree.search(20)).to eq('b')
    end

    it 'keeps keys in sorted order' do
      expect(tree.keys).to eq([5, 10, 20])
    end
  end

  describe 'index-style access' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b']]) }

    it 'reads values with []' do
      expect(tree[20]).to eq('b')
    end

    it 'updates values with []=' do
      tree[20] = 'z'
      expect(tree.search(20)).to eq('z')
    end
  end

  describe 'delete' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b'], [5, 'c']]) }

    it 'returns the deleted value' do
      expect(tree.delete(5)).to eq('c')
    end

    it 'removes the key from lookup results' do
      tree.delete(5)
      expect(tree.search(5)).to be_nil
    end

    it 'keeps ordered keys after deletion' do
      tree.delete(5)
      expect(tree.keys).to eq([10, 20])
    end
  end

  describe 'enumeration and serialization usage' do
    let(:tree) { build_tree([[10, 'a'], [5, 'b'], [20, 'c']]) }

    it 'enumerates entries in key order' do
      pairs = tree.map { |entry| [entry.key, entry.value] }
      expect(pairs).to eq([[5, 'b'], [10, 'a'], [20, 'c']])
    end

    it 'round-trips via hash conversion' do
      rebuilt = described_class.from_hash(tree.to_h)
      expect(rebuilt.to_a).to eq(tree.to_a)
    end
  end

  describe 'shovel insertion' do
    let(:tree) { build_tree([]) }

    it 'returns the inserted entry' do
      expect((tree << [10, 'a']).key).to eq(10)
    end

    it 'stores the inserted value' do
      tree << [10, 'a']
      expect(tree.search(10)).to eq('a')
    end
  end

  describe 'input validation' do
    it 'rejects nil keys' do
      tree = build_tree([])
      expect { tree.insert(nil, 'a') }.to raise_error(ArgumentError)
    end
  end
end
