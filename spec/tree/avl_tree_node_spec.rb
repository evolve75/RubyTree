# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/avltree'

RSpec.describe Tree::AvlTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def avl_valid?(node)
    root = node.root
    return true unless root.content

    balance_valid?(root) && heights_valid?(root)
  end

  def balance_valid?(node)
    return true unless node

    balance = height_of(node.left_child) - height_of(node.right_child)
    return false unless (-1..1).include?(balance)

    balance_valid?(node.left_child) && balance_valid?(node.right_child)
  end

  def heights_valid?(node)
    return true unless node

    expected = 1 + [height_of(node.left_child), height_of(node.right_child)].max
    return false unless node.height == expected

    heights_valid?(node.left_child) && heights_valid?(node.right_child)
  end

  def height_of(node)
    node&.height.to_i
  end

  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8]) }

  it 'finds inserted keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'returns nil for missing keys' do
    expect(root.search(7)).to be_nil
  end

  it 'keeps in-order traversal sorted' do
    expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
  end

  it 'maintains AVL invariants after inserts' do
    expect(avl_valid?(root)).to be(true)
  end

  describe 'delete usage' do
    before { root.delete(12) }

    it 'removes deleted keys from search' do
      expect(root.search(12)).to be_nil
    end

    it 'keeps in-order traversal sorted after delete' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains AVL invariants after delete' do
      expect(avl_valid?(root)).to be(true)
    end
  end
end
