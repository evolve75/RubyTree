# test_binaryheap.rb - This file is part of the RubyTree package.
#
# Copyright (c) 2026 Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
#
# - Neither the name of the organization nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/tree/binaryheap'

module TestTree
  # Test class for the binary heap node.
  class TestBinaryHeapNode < Test::Unit::TestCase
    def heap_valid?(node)
      root = node.root
      return true unless root.content

      heap_valid_node?(root)
    end

    def heap_valid_node?(node)
      return true unless node

      left = node.left_child
      right = node.right_child
      return false if left && left.content < node.content
      return false if right && right.content < node.content

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

    def build_heap(values)
      root = Tree::BinaryHeapNode.new('root', values.first)
      values.drop(1).each_with_index do |value, idx|
        root.insert("n#{idx}", value)
      end
      root
    end

    def test_insert_maintains_invariants
      root = build_heap([10, 5, 15, 2, 7, 12, 20])

      assert_equal(true, heap_valid?(root))
      assert_equal(true, complete?(root))
    end

    def test_peek
      root = build_heap([10, 5, 15, 2, 7])

      assert_equal(2, root.peek)
      assert_equal(2, root.peek)
      assert_equal(true, heap_valid?(root))
    end

    def test_extract_returns_sorted
      values = [10, 5, 15, 2, 7, 12]
      root = build_heap(values)

      extracted = []
      loop do
        value = root.extract
        break unless value

        extracted << value
        assert_equal(true, heap_valid?(root))
        assert_equal(true, complete?(root))
      end

      assert_equal(values.sort, extracted)
    end

    def test_search
      root = build_heap([10, 5, 15, 2, 7])

      assert_equal(7, root.search(7).content)
      assert_nil(root.search(99))
    end

    def test_delete
      root = build_heap([10, 5, 15, 2, 7, 12])
      removed = root.delete(7)

      assert_equal(7, removed.content)
      assert_equal(true, heap_valid?(root))
      assert_equal(true, complete?(root))
    end
  end
end
