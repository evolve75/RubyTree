# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/binaryheap'

RSpec.describe Tree::BinaryHeapNode do
  def build_heap(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  def extract_all(node)
    values = []
    while (value = node.extract)
      values << value
    end
    values
  end

  describe 'priority queue usage' do
    let(:heap) { build_heap([10, 5, 15, 2, 7]) }

    it 'peeks the minimum value' do
      expect(heap.peek).to eq(2)
    end

    it 'keeps the minimum after peek' do
      heap.peek
      expect(heap.peek).to eq(2)
    end
  end

  describe 'sorted extraction usage' do
    it 'extracts values in ascending order' do
      values = [10, 5, 15, 2, 7, 12]
      heap = build_heap(values)
      expect(extract_all(heap)).to eq(values.sort)
    end
  end

  describe 'search and delete usage' do
    let(:heap) { build_heap([10, 5, 15, 2, 7, 12]) }

    it 'finds an inserted key' do
      expect(heap.search(7).content).to eq(7)
    end

    it 'returns the deleted node' do
      expect(heap.delete(7).content).to eq(7)
    end

    it 'removes deleted keys from search' do
      heap.delete(7)
      expect(heap.search(7)).to be_nil
    end

    it 'returns nil for missing keys' do
      expect(heap.search(99)).to be_nil
    end
  end
end
