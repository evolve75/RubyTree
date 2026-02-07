# test_treap.rb - This file is part of the RubyTree package.
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
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/tree/treap'

module TestTree
  # Test class for the treap node.
  class TestTreapNode < Test::Unit::TestCase
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
      root = Tree::TreapNode.new('root', first_key, priority: first_priority)
      pairs.drop(1).each_with_index do |(key, priority), idx|
        root.insert("n#{idx}", key, priority: priority)
      end
      root
    end

    def test_insert_maintains_invariants
      root = build_tree([[10, 50], [5, 30], [15, 70], [12, 40], [18, 90], [2, 10]])

      assert_equal(inorder_contents(root).sort, inorder_contents(root))
      assert_equal(true, treap_valid?(root))
    end

    def test_search
      root = build_tree([[10, 50], [5, 30], [15, 70]])

      assert_equal(15, root.search(15).content)
      assert_nil(root.search(7))
    end

    def test_delete_leaf
      root = build_tree([[10, 50], [5, 30], [15, 70], [2, 10]])
      root.delete(2)

      assert_equal(inorder_contents(root).sort, inorder_contents(root))
      assert_equal(true, treap_valid?(root))
    end

    def test_delete_node_with_one_child
      root = build_tree([[10, 50], [5, 30], [2, 40]])
      root.delete(5)

      assert_equal(inorder_contents(root).sort, inorder_contents(root))
      assert_equal(true, treap_valid?(root))
    end

    def test_delete_node_with_two_children
      root = build_tree([[10, 50], [5, 30], [15, 70], [12, 40], [18, 90], [2, 10]])
      root.delete(15)

      assert_equal(inorder_contents(root).sort, inorder_contents(root))
      assert_equal(true, treap_valid?(root))
    end

    def test_delete_root
      root = build_tree([[10, 50], [5, 30], [15, 70], [12, 40]])
      root.delete(10)

      assert_equal(inorder_contents(root.root).sort, inorder_contents(root.root))
      assert_equal(true, treap_valid?(root))
    end
  end
end
