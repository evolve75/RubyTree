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

  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2]) }

  it 'orders inserts by key' do
    expect(inorder_contents(root)).to eq([2, 5, 10, 12, 15, 18])
  end

  it 'finds matching keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'returns nil for missing keys' do
    expect(root.search(7)).to be_nil
  end

  describe 'delete usage' do
    it 'returns the removed node' do
      expect(root.delete(2).content).to eq(2)
    end

    it 'removes deleted keys from traversal results' do
      root.delete(15)
      expect(inorder_contents(root)).to eq([2, 5, 10, 12, 18])
    end
  end
end
