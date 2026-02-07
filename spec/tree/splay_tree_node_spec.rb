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
    values.drop(1).each_with_index do |value, idx|
      root.insert("n#{idx}", value)
    end
    root
  end

  describe 'inserts' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end

    it 'maintains BST invariants' do
      expect(bst_valid?(root.root, nil, nil)).to be(true)
    end
  end

  describe 'search' do
    let(:root) { build_tree([10, 5, 15, 12]) }

    it 'finds an existing key' do
      expect(root.search(15).content).to eq(15)
    end

    it 'splays the found key to root' do
      root.search(12)
      expect(root.root.content).to eq(12)
    end

    it 'returns nil for a missing key' do
      expect(root.search(7)).to be_nil
    end
  end

  describe 'delete' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2]) }

    it 'removes a leaf node' do
      root.delete(2)
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end

    it 'removes a node with one child' do
      root.delete(5)
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end

    it 'removes a node with two children' do
      root.delete(15)
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end
  end
end
