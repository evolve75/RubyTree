# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/aatree'

RSpec.describe Tree::AATree do
  def build_tree(entries)
    described_class.new(entries)
  end

  describe 'insert' do
    it 'keeps keys ordered' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e']])
      expect(tree.keys).to eq(tree.keys.sort)
    end
  end

  describe 'search' do
    it 'finds an existing key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])
      expect(tree.search(20)).to eq('b')
    end

    it 'returns nil for a missing key' do
      tree = build_tree([[10, 'a'], [20, 'b']])
      expect(tree.search(99)).to be_nil
    end
  end

  describe 'delete' do
    it 'removes a leaf key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])
      expect(tree.delete(5)).to eq('c')
    end

    it 'removes the key from the tree' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])
      tree.delete(5)
      expect(tree.search(5)).to be_nil
    end

    it 'keeps keys ordered after delete' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e']])
      tree.delete(10)
      expect(tree.keys).to eq(tree.keys.sort)
    end
  end

  describe 'initialize' do
    it 'accepts array entries' do
      tree = build_tree([[1, 'a'], [2, 'b']])
      expect(tree.to_a).to eq([[1, 'a'], [2, 'b']])
    end

    it 'accepts hash entries' do
      tree = build_tree([{ key: 2, value: 'b' }, { key: 1, value: 'a' }])
      expect(tree.to_a).to eq([[1, 'a'], [2, 'b']])
    end
  end

  describe '[]' do
    it 'returns the value for a key' do
      tree = build_tree([[10, 'a'], [20, 'b']])
      expect(tree[20]).to eq('b')
    end
  end

  describe '[]=' do
    it 'updates the value for a key' do
      tree = build_tree([[10, 'a'], [20, 'b']])
      tree[20] = 'z'
      expect(tree.search(20)).to eq('z')
    end
  end

  describe 'each' do
    it 'yields entries in key order' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      expect(tree.map(&:key)).to eq([5, 10, 20])
    end
  end

  describe 'preordered_each' do
    it 'yields all keys' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.preordered_each.map(&:key)
      expect(keys.sort).to eq([5, 10, 15, 20])
    end
  end

  describe 'postordered_each' do
    it 'yields all keys' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.postordered_each.map(&:key)
      expect(keys.sort).to eq([5, 10, 15, 20])
    end
  end

  describe 'breadth_each' do
    it 'yields all keys' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.breadth_each.map(&:key)
      expect(keys.sort).to eq([5, 10, 15, 20])
    end
  end

  describe 'keys' do
    it 'returns keys in order' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      expect(tree.keys).to eq([5, 10, 20])
    end
  end

  describe 'values' do
    it 'returns values in key order' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      expect(tree.values).to eq(%w[b a c])
    end
  end

  describe 'to_a' do
    it 'returns key/value pairs in order' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      expect(tree.to_a).to eq([[5, 'b'], [10, 'a'], [20, 'c']])
    end
  end

  describe 'to_h and from_hash' do
    it 'round trips the tree' do
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      rebuilt = described_class.from_hash(tree.to_h)
      expect(rebuilt.to_a).to eq(tree.to_a)
    end
  end

  describe 'as_json' do
    it 'returns a hash representation' do
      tree = build_tree([[10, 'a']])
      expect(tree.as_json).to be_a(Hash)
    end
  end

  describe '<=>' do
    it 'compares by ordered entries' do
      left = build_tree([[10, 'a'], [5, 'b']])
      right = build_tree([[10, 'a'], [5, 'c']])
      expect(left <=> right).to eq(-1)
    end
  end

  describe 'input validation' do
    it 'rejects nil keys' do
      tree = build_tree([])
      expect { tree.insert(nil, 'a') }.to raise_error(ArgumentError)
    end
  end

  describe '<<' do
    it 'returns the inserted entry' do
      tree = build_tree([])
      inserted = tree << [10, 'a']

      expect(inserted.key).to eq(10)
    end

    it 'stores the inserted key/value pair' do
      tree = build_tree([])
      tree << [10, 'a']

      expect(tree.search(10)).to eq('a')
    end
  end
end
