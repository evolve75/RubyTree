# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/intervaltree'

RSpec.describe Tree::IntervalTreeNode do
  def build_tree(intervals)
    root = described_class.new('root', intervals.first)
    intervals.drop(1).each_with_index do |interval, idx|
      root.insert("n#{idx}", interval)
    end
    root
  end

  def inorder_keys(node)
    result = []
    node.inordered_each { |entry| result << entry.key }
    result
  end

  def max_end_valid?(node)
    return true unless node&.content

    expected = [node.interval_end, node.left_child&.max_end, node.right_child&.max_end].compact.max
    return false unless expected == node.max_end

    max_end_valid?(node.left_child) && max_end_valid?(node.right_child)
  end

  describe 'inserts' do
    let(:root) { build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40]) }

    it 'keeps in-order traversal sorted' do
      expect(inorder_keys(root)).to eq(inorder_keys(root).sort)
    end

    it 'maintains max_end across the subtree' do
      expect(max_end_valid?(root)).to be(true)
    end
  end

  describe 'search_overlaps' do
    let(:root) { build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40]) }

    it 'returns all overlapping intervals' do
      results = root.search_overlaps(14..16).map(&:content)
      expected = [15..20, 10..30, 5..20, 12..15]
      expect(results.sort_by(&:begin)).to eq(expected.sort_by(&:begin))
    end
  end

  describe 'search_point' do
    let(:root) { build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40]) }

    it 'returns all intervals covering the point' do
      results = root.search_point(17).map(&:content)
      expected = [15..20, 10..30, 17..19, 5..20]
      expect(results.sort_by(&:begin)).to eq(expected.sort_by(&:begin))
    end
  end

  describe 'delete' do
    let(:root) { build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40]) }

    before { root.delete(10..30) }

    it 'maintains max_end across the subtree' do
      expect(max_end_valid?(root)).to be(true)
    end
  end
end
