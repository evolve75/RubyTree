# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/fenwicktree'

RSpec.describe Tree::FenwickTree do
  def build_tree(values)
    described_class.new(values.length, values)
  end

  let(:tree) { build_tree([1, 2, 3, 4, 5]) }

  it 'supports prefix-sum queries for common usage' do
    expect(tree.sum(3)).to eq(10)
  end

  it 'supports range-sum queries for common usage' do
    expect(tree.range_sum(1, 3)).to eq(9)
  end

  it 'supports indexed updates via []=' do
    tree[1] = 5
    expect(tree[1]).to eq(7)
  end

  it 'supports enumeration in index order' do
    expect(tree.each.to_a).to eq([1, 2, 3, 4, 5])
  end

  it 'supports hash round-trips' do
    copy = described_class.from_hash(tree.to_h)
    expect(copy.to_a).to eq(tree.to_a)
  end

  it 'rejects invalid tree size' do
    expect { described_class.new(0) }.to raise_error(ArgumentError)
  end

  it 'does not support shovel insertion' do
    expect(tree.respond_to?(:<<)).to be(false)
  end
end
