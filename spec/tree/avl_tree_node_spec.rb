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
    values.drop(1).each_with_index do |value, idx|
      root.insert("n#{idx}", value)
    end
    root
  end

  describe 'inserts' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains AVL invariants' do
      expect(avl_valid?(root)).to be(true)
    end
  end

  describe 'search' do
    let(:root) { build_tree([10, 5, 15]) }

    it 'finds an existing key' do
      expect(root.search(15).content).to eq(15)
    end

    it 'returns nil for a missing key' do
      expect(root.search(7)).to be_nil
    end
  end

  describe 'delete leaf' do
    let(:root) { build_tree([10, 5, 15, 2]) }

    before { root.delete(2) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains AVL invariants' do
      expect(avl_valid?(root)).to be(true)
    end
  end

  describe 'delete node with one child' do
    let(:root) { build_tree([10, 5, 2]) }

    before { root.delete(5) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains AVL invariants' do
      expect(avl_valid?(root)).to be(true)
    end
  end

  describe 'delete node with two children' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2]) }

    before { root.delete(15) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains AVL invariants' do
      expect(avl_valid?(root)).to be(true)
    end
  end

  describe 'delete root' do
    let(:root) { build_tree([10, 5, 15, 12]) }

    before { root.delete(10) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end

    it 'maintains AVL invariants' do
      expect(avl_valid?(root)).to be(true)
    end
  end
end
