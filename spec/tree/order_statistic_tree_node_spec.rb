# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/orderstatistictree'

RSpec.describe Tree::OrderStatisticTreeNode do
  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, idx|
      root.insert("n#{idx}", value)
    end
    root
  end

  def subtree_size_valid?(node)
    return true unless node&.content

    return false unless subtree_size_matches?(node)
    return false unless subtree_size_valid?(node.left_child)

    subtree_size_valid?(node.right_child)
  end

  def subtree_size_matches?(node)
    left_size = node.left_child&.subtree_size || 0
    right_size = node.right_child&.subtree_size || 0
    (left_size + right_size + 1) == node.subtree_size
  end

  describe 'inserts' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    it 'maintains subtree sizes' do
      expect(subtree_size_valid?(root)).to be(true)
    end
  end

  describe 'rank' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    it 'returns the smallest key rank' do
      expect(root.rank(1)).to eq(0)
    end

    it 'returns the middle key rank' do
      expect(root.rank(10)).to eq(5)
    end

    it 'returns the largest key rank' do
      expect(root.rank(18)).to eq(8)
    end

    it 'returns nil for missing keys' do
      expect(root.rank(7)).to be_nil
    end
  end

  describe 'select' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    it 'returns the first node by rank' do
      expect(root.select(0).content).to eq(1)
    end

    it 'returns the middle node by rank' do
      expect(root.select(4).content).to eq(8)
    end

    it 'returns the next node by rank' do
      expect(root.select(5).content).to eq(10)
    end

    it 'returns the last node by rank' do
      expect(root.select(8).content).to eq(18)
    end

    it 'returns nil for out of range indices' do
      expect(root.select(9)).to be_nil
    end

    it 'returns nil for negative indices' do
      expect(root.select(-1)).to be_nil
    end
  end

  describe 'delete' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    before { root.delete(12) }

    it 'maintains subtree sizes' do
      expect(subtree_size_valid?(root)).to be(true)
    end
  end
end
