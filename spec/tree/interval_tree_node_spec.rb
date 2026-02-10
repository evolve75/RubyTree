# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/intervaltree'

RSpec.describe Tree::IntervalTreeNode do
  def build_tree(intervals)
    root = described_class.new('root', intervals.first)
    intervals.drop(1).each_with_index do |interval, index|
      root.insert("n#{index}", interval)
    end
    root
  end

  def max_end_valid?(node)
    return true unless node&.content

    expected = [node.interval_end, node.left_child&.max_end, node.right_child&.max_end].compact.max
    return false unless expected == node.max_end

    max_end_valid?(node.left_child) && max_end_valid?(node.right_child)
  end

  let(:root) { build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40]) }

  it 'supports overlap queries for common usage' do
    results = root.search_overlaps(14..16).map(&:content)
    expect(results.sort_by(&:begin)).to eq([5..20, 10..30, 12..15, 15..20])
  end

  it 'supports point queries for common usage' do
    results = root.search_point(17).map(&:content)
    expect(results.sort_by(&:begin)).to eq([5..20, 10..30, 15..20, 17..19])
  end

  it 'maintains max_end metadata after inserts' do
    expect(max_end_valid?(root)).to be(true)
  end

  it 'maintains max_end metadata after delete' do
    root.delete(10..30)
    expect(max_end_valid?(root)).to be(true)
  end
end
