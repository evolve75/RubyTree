# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/treap'

RSpec.describe Tree::TreapNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def treap_valid?(node)
    root = node.root
    return true unless root.content

    bst_valid?(root, nil, nil) && heap_valid?(root)
  end

  def bst_valid?(node, min, max)
    return true unless node

    return false if min && node.content < min
    return false if max && node.content > max

    bst_valid?(node.left_child, min, node.content) && bst_valid?(node.right_child, node.content, max)
  end

  def heap_valid?(node)
    return true unless node

    left = node.left_child
    right = node.right_child
    return false if left && left.priority < node.priority
    return false if right && right.priority < node.priority

    heap_valid?(left) && heap_valid?(right)
  end

  def build_tree(pairs)
    first_key, first_priority = pairs.first
    root = described_class.new('root', first_key, priority: first_priority)
    pairs.drop(1).each_with_index do |(key, priority), index|
      root.insert("n#{index}", key, priority: priority)
    end
    root
  end

  let(:root) { build_tree([[10, 50], [5, 30], [15, 70], [12, 40], [18, 90], [2, 10]]) }

  it 'finds inserted keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'returns nil for missing keys' do
    expect(root.search(7)).to be_nil
  end

  it 'keeps in-order traversal sorted' do
    expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
  end

  it 'maintains treap invariants after inserts' do
    expect(treap_valid?(root)).to be(true)
  end

  describe 'delete usage' do
    before { root.delete(12) }

    it 'removes deleted keys from search' do
      expect(root.search(12)).to be_nil
    end

    it 'keeps in-order traversal sorted after delete' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains treap invariants after delete' do
      expect(treap_valid?(root)).to be(true)
    end
  end
end
