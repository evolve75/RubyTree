# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/fenwicktree'

RSpec.describe Tree::FenwickTree do
  def build_tree(values)
    described_class.new(values.length, values)
  end

  describe 'initialize' do
    it 'applies initial values' do
      tree = build_tree([1, 2, 3])
      expect(tree.sum(2)).to eq(6)
    end

    it 'raises for invalid size' do
      expect { described_class.new(0) }.to raise_error(ArgumentError)
    end
  end

  describe 'update' do
    it 'updates prefix sums' do
      tree = build_tree([1, 2, 3, 4])
      tree.update(2, 5)
      expect(tree.sum(2)).to eq(11)
    end
  end

  describe 'sum' do
    it 'returns a prefix sum' do
      tree = build_tree([1, 2, 3, 4, 5])
      expect(tree.sum(3)).to eq(10)
    end
  end

  describe 'range_sum' do
    it 'returns a range sum' do
      tree = build_tree([1, 2, 3, 4, 5])
      expect(tree.range_sum(1, 3)).to eq(9)
    end
  end

  describe '[]' do
    it 'returns the value at an index' do
      tree = build_tree([1, 2, 3, 4, 5])
      expect(tree[4]).to eq(5)
    end
  end

  describe '[]=' do
    it 'adds a delta at the index' do
      tree = build_tree([1, 2, 3])
      tree[1] = 5
      expect(tree[1]).to eq(7)
    end
  end

  describe 'each' do
    it 'yields values in index order' do
      tree = build_tree([3, 1, 4])
      expect(tree.each.to_a).to eq([3, 1, 4])
    end
  end

  describe 'keys' do
    it 'returns indices in order' do
      tree = build_tree([1, 2, 3])
      expect(tree.keys).to eq([0, 1, 2])
    end
  end

  describe 'values' do
    it 'returns values in index order' do
      tree = build_tree([2, 4, 6])
      expect(tree.values).to eq([2, 4, 6])
    end
  end

  describe 'to_h and from_hash' do
    it 'round trips the tree' do
      tree = build_tree([1, 3, 5])
      copy = described_class.from_hash(tree.to_h)
      expect(copy.to_a).to eq([1, 3, 5])
    end
  end

  describe 'as_json' do
    it 'returns a hash representation' do
      tree = build_tree([1, 2])
      expect(tree.as_json).to eq(tree.to_h)
    end
  end

  describe '<=>' do
    it 'compares by ordered values' do
      left = build_tree([1, 2, 3])
      right = build_tree([1, 2, 4])
      expect(left < right).to be(true)
    end
  end
end
