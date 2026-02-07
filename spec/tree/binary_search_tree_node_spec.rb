# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/binarysearchtree'

RSpec.describe Tree::BinarySearchTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def build_leaf_tree
    root = described_class.new('root', 10)
    root.insert('n5', 5)
    root.insert('n15', 15)
    root.insert('n2', 2)
    root
  end

  def build_one_child_tree
    root = described_class.new('root', 10)
    root.insert('n5', 5)
    root.insert('n2', 2)
    root
  end

  def build_two_children_tree
    root = described_class.new('root', 10)
    root.insert('n5', 5)
    root.insert('n15', 15)
    root.insert('n12', 12)
    root.insert('n18', 18)
    root.insert('n2', 2)
    root
  end

  def build_root_single_child_tree
    root = described_class.new('root', 10)
    root.insert('n5', 5)
    root
  end

  def build_root_leaf_tree
    described_class.new('root', 10)
  end

  it 'orders inserts by key' do
    expect(inorder_contents(build_two_children_tree)).to eq([2, 5, 10, 12, 15, 18])
  end

  it 'finds a matching key' do
    expect(build_two_children_tree.search(15).name).to eq('n15')
  end

  it 'returns nil for a missing key' do
    expect(build_two_children_tree.search(7)).to be_nil
  end

  it 'returns the removed node when deleting a leaf' do
    expect(build_leaf_tree.delete(2).content).to eq(2)
  end

  it 'updates order when deleting a leaf' do
    root = build_leaf_tree
    root.delete(2)
    expect(inorder_contents(root)).to eq([5, 10, 15])
  end

  it 'updates order when deleting a node with one child' do
    root = build_one_child_tree
    root.delete(5)
    expect(inorder_contents(root)).to eq([2, 10])
  end

  it 'updates order when deleting a node with two children' do
    root = build_two_children_tree
    root.delete(15)
    expect(inorder_contents(root)).to eq([2, 5, 10, 12, 18])
  end

  it 'replaces root content when deleting root with one child' do
    root = build_root_single_child_tree
    root.delete(10)
    expect(root.content).to eq(5)
  end

  it 'clears root content when deleting a root leaf' do
    root = build_root_leaf_tree
    root.delete(10)
    expect(root.content).to be_nil
  end
end
