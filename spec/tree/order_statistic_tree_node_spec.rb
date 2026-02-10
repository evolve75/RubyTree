# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/orderstatistictree'

RSpec.describe Tree::OrderStatisticTreeNode do
  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  def subtree_size_valid?(node)
    return true unless node&.content

    return false unless subtree_size_matches?(node)

    subtree_size_valid?(node.left_child) && subtree_size_valid?(node.right_child)
  end

  def subtree_size_matches?(node)
    left_size = node.left_child&.subtree_size || 0
    right_size = node.right_child&.subtree_size || 0
    node.subtree_size == left_size + right_size + 1
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

  it 'supports rank queries for common usage' do
    expect(root.rank(10)).to eq(5)
  end

  it 'supports select queries for common usage' do
    expect(root.select(4).content).to eq(8)
  end

  it 'returns nil for missing ranks' do
    expect(root.rank(7)).to be_nil
  end

  it 'maintains subtree-size metadata after inserts' do
    expect(subtree_size_valid?(root)).to be(true)
  end

  it 'maintains subtree-size metadata after delete' do
    root.delete(12)
    expect(subtree_size_valid?(root)).to be(true)
  end
end
