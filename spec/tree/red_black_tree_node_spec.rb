# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/redblacktree'

RSpec.describe Tree::RedBlackTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def red_black_valid?(node)
    root = node.root
    return true unless root.content
    return false unless root.black?

    red_children_valid?(root) && black_height_valid?(root)
  end

  def red_children_valid?(node)
    return true unless node
    return false if node.red? && (node.left_child&.red? || node.right_child&.red?)

    red_children_valid?(node.left_child) && red_children_valid?(node.right_child)
  end

  def black_height_valid?(node)
    target = nil
    check = lambda do |current, count|
      if current.nil?
        target ||= count
        return count == target
      end

      count += 1 if current.black?
      check.call(current.left_child, count) && check.call(current.right_child, count)
    end

    check.call(node, 0)
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

    it 'keeps red-black invariants' do
      expect(red_black_valid?(root)).to be(true)
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

    it 'keeps red-black invariants' do
      expect(red_black_valid?(root)).to be(true)
    end
  end

  describe 'delete node with one child' do
    let(:root) { build_tree([10, 5, 2]) }

    before { root.delete(5) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'keeps red-black invariants' do
      expect(red_black_valid?(root)).to be(true)
    end
  end

  describe 'delete node with two children' do
    let(:root) { build_tree([10, 5, 15, 12, 18, 2]) }

    before { root.delete(15) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'keeps red-black invariants' do
      expect(red_black_valid?(root)).to be(true)
    end
  end

  describe 'delete root' do
    let(:root) { build_tree([10, 5, 15, 12]) }

    before { root.delete(10) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
    end

    it 'keeps red-black invariants' do
      expect(red_black_valid?(root)).to be(true)
    end
  end
end
