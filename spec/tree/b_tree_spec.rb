# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/btree'

RSpec.describe Tree::BTree do
  def build_tree(values, min_degree: 2)
    entries = values.map { |(key, value)| { key: key, value: value } }
    described_class.new(min_degree, entries)
  end

  def inorder_keys(node, result = [])
    if node.leaf
      result.concat(node.entries.map(&:key))
      return result
    end

    node.entries.each_with_index do |entry, index|
      inorder_keys(node.children[index], result)
      result << entry.key
    end
    inorder_keys(node.children[node.entries.length], result)
  end

  describe 'insert' do
    it 'keeps keys ordered' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      expect(inorder_keys(tree.root)).to eq(inorder_keys(tree.root).sort)
    end
  end

  describe 'search' do
    it 'finds an existing key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      expect(tree.search(12)).to eq('e')
    end

    it 'returns nil for a missing key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])
      expect(tree.search(99)).to be_nil
    end
  end

  describe 'delete' do
    it 'removes a leaf key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      expect(tree.delete(7)).to eq('g')
    end

    it 'removes the leaf key from the tree' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      tree.delete(7)
      expect(tree.search(7)).to be_nil
    end

    it 'keeps keys ordered after deleting a leaf key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      tree.delete(7)
      expect(inorder_keys(tree.root)).to eq(inorder_keys(tree.root).sort)
    end

    it 'removes an internal key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      expect(tree.delete(10)).to eq('a')
    end

    it 'removes the internal key from the tree' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      tree.delete(10)
      expect(tree.search(10)).to be_nil
    end

    it 'keeps keys ordered after deleting an internal key' do
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      tree.delete(10)
      expect(inorder_keys(tree.root)).to eq(inorder_keys(tree.root).sort)
    end

    it 'updates the root when needed' do
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd'], [5, 'e'], [6, 'f'], [7, 'g'], [8, 'h']])
      expect(tree.delete(1)).to eq('a')
    end

    it 'removes the key after root updates' do
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd'], [5, 'e'], [6, 'f'], [7, 'g'], [8, 'h']])
      tree.delete(1)
      expect(tree.search(1)).to be_nil
    end

    it 'keeps keys ordered after root updates' do
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd'], [5, 'e'], [6, 'f'], [7, 'g'], [8, 'h']])
      tree.delete(1)
      expect(inorder_keys(tree.root)).to eq(inorder_keys(tree.root).sort)
    end
  end

  describe 'initialize' do
    it 'raises for invalid min degree' do
      expect { described_class.new(1) }.to raise_error(ArgumentError)
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

  describe 'height' do
    it 'returns 0 for a leaf root' do
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c']])
      expect(tree.height).to eq(0)
    end

    it 'returns a positive height after splits' do
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd']])
      expect(tree.height).to be >= 1
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
      right = build_tree([[10, 'a'], [5, 'b']])
      expect(left <=> right).to eq(0)
    end

    it 'returns nil for non-btree comparisons' do
      tree = build_tree([[10, 'a']])
      expect(tree <=> 123).to be_nil
    end
  end

  describe '<<' do
    it 'returns the inserted entry' do
      tree = described_class.new(2)
      inserted = tree << [10, 'a']

      expect(inserted.key).to eq(10)
    end

    it 'stores the inserted key/value pair' do
      tree = described_class.new(2)
      tree << [10, 'a']

      expect(tree.search(10)).to eq('a')
    end
  end
end
