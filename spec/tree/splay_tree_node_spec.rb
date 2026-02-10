# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/splaytree'

RSpec.describe Tree::SplayTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def bst_valid?(node, min, max)
    return true unless node
    return false if min && node.content < min
    return false if max && node.content > max

    bst_valid?(node.left_child, min, node.content) && bst_valid?(node.right_child, node.content, max)
  end

  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8]) }

  it 'keeps in-order traversal sorted after inserts' do
    expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
  end

  it 'maintains BST invariants after inserts' do
    expect(bst_valid?(root.root, nil, nil)).to be(true)
  end

  it 'finds existing keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'splays found keys to the root' do
    root.search(12)
    expect(root.root.content).to eq(12)
  end

  it 'supports delete in common mutation flows' do
    root.delete(15)
    expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
  end
end
