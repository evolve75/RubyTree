# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/segmenttree'

RSpec.describe Tree::SegmentTree do
  def build_tree(values)
    described_class.new(values.length, values)
  end

  describe 'initialize' do
    it 'applies initial values' do
      tree = build_tree([1, 2, 3])
      expect(tree.range_sum(0, 2)).to eq(6)
    end

    it 'raises for invalid size' do
      expect { described_class.new(0) }.to raise_error(ArgumentError)
    end
  end

  describe 'update' do
    it 'updates range sums' do
      tree = build_tree([1, 2, 3, 4])
      tree.update(2, 10)
      expect(tree.range_sum(1, 3)).to eq(16)
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
end
