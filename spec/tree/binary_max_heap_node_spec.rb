# frozen_string_literal: true

require 'rspec'
require 'spec_helper'
require 'tree/binarymaxheap'

RSpec.describe Tree::BinaryMaxHeapNode do
  def heap_valid?(node)
    root = node.root
    return true unless root.content

    heap_valid_node?(root)
  end

  def heap_valid_node?(node)
    return true unless node

    left = node.left_child
    right = node.right_child
    return false if left && left.content > node.content
    return false if right && right.content > node.content

    heap_valid_node?(left) && heap_valid_node?(right)
  end

  def complete?(node)
    root = node.root
    return true unless root.content

    queue = [root]
    seen_nil = false
    index = 0
    while index < queue.length
      current = queue[index]
      index += 1

      if current.nil?
        seen_nil = true
        next
      end

      return false if seen_nil

      queue << current.left_child
      queue << current.right_child
    end

    true
  end

  def heap_invariants?(node)
    heap_valid?(node) && complete?(node)
  end

  def extract_all(node)
    values = []
    while (value = node.extract)
      values << value
    end
    values
  end

  def extract_preserves_invariants?(node)
    loop do
      value = node.extract
      return true unless value
      return false unless heap_invariants?(node)
    end
  end

  def build_heap(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, idx|
      root.insert("n#{idx}", value)
    end
    root
  end

  describe 'insert' do
    let(:root) { build_heap([10, 5, 15, 2, 7, 12, 20]) }

    it 'maintains heap invariants' do
      expect(heap_invariants?(root)).to be(true)
    end
  end

  describe 'peek' do
    it 'returns the maximum value' do
      root = build_heap([10, 5, 15, 2, 7])
      expect(root.peek).to eq(15)
    end

    it 'does not remove the maximum value' do
      root = build_heap([10, 5, 15, 2, 7])
      root.peek
      expect(root.peek).to eq(15)
    end
  end

  describe 'extract' do
    it 'returns values in sorted order' do
      values = [10, 5, 15, 2, 7, 12]
      root = build_heap(values)

      expect(extract_all(root)).to eq(values.sort.reverse)
    end

    it 'maintains heap invariants during extraction' do
      root = build_heap([10, 5, 15, 2, 7, 12])

      expect(extract_preserves_invariants?(root)).to be(true)
    end
  end

  describe 'search' do
    it 'finds an existing key' do
      root = build_heap([10, 5, 15, 2, 7])
      expect(root.search(7).content).to eq(7)
    end

    it 'returns nil for a missing key' do
      root = build_heap([10, 5, 15])
      expect(root.search(99)).to be_nil
    end
  end

  describe 'delete' do
    it 'returns the removed node' do
      root = build_heap([10, 5, 15, 2, 7, 12])
      removed = root.delete(7)

      expect(removed.content).to eq(7)
    end

    it 'keeps heap invariants after deletion' do
      root = build_heap([10, 5, 15, 2, 7, 12])
      root.delete(7)

      expect(heap_invariants?(root)).to be(true)
    end
  end
end
