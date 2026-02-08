# test_btree.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/btree'

module TestTree
  # Test class for the B-tree.
  class TestBTree < Test::Unit::TestCase
    def build_tree(values, min_degree: 2)
      entries = values.map { |(key, value)| { key: key, value: value } }
      Tree::BTree.new(min_degree, entries)
    end

    def inorder_keys(node, result = [])
      if node.leaf
        result.concat(node.entries.map(&:key))
        return result
      end

      node.entries.each_with_index do |entry, index|
        inorder_keys(node.children[index], result)
        result << entry.key
      end
      inorder_keys(node.children[node.entries.length], result)
    end

    def test_insert_keeps_ordered
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])

      assert_equal(inorder_keys(tree.root).sort, inorder_keys(tree.root))
    end

    def test_search
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])

      assert_equal('e', tree.search(12))
      assert_nil(tree.search(99))
    end

    def test_delete_leaf
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      assert_equal('g', tree.delete(7))

      assert_nil(tree.search(7))
      assert_equal(inorder_keys(tree.root).sort, inorder_keys(tree.root))
    end

    def test_delete_internal
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e'], [30, 'f'], [7, 'g'], [17, 'h']])
      assert_equal('a', tree.delete(10))

      assert_nil(tree.search(10))
      assert_equal(inorder_keys(tree.root).sort, inorder_keys(tree.root))
    end

    def test_invalid_min_degree
      assert_raise(ArgumentError) { Tree::BTree.new(1) }
    end

    def test_index_accessor
      tree = build_tree([[10, 'a'], [20, 'b']])

      assert_equal('b', tree[20])
    end

    def test_index_assignment
      tree = build_tree([[10, 'a'], [20, 'b']])
      tree[20] = 'z'

      assert_equal('z', tree.search(20))
    end

    def test_each_yields_keys_in_order
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      keys = tree.map(&:key)

      assert_equal([5, 10, 20], keys)
    end

    def test_keys_returns_ordered_keys
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])

      assert_equal([5, 10, 20], tree.keys)
    end

    def test_values_returns_ordered_values
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])

      assert_equal(%w[b a c], tree.values)
    end

    def test_to_a_returns_pairs
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])

      assert_equal([[5, 'b'], [10, 'a'], [20, 'c']], tree.to_a)
    end

    def test_comparison
      left = build_tree([[10, 'a'], [5, 'b']])
      right = build_tree([[10, 'a'], [5, 'b']])

      assert_equal(0, left <=> right)
      assert_nil(left <=> 123)
    end

    def test_preordered_each_yields_all_keys
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.preordered_each.map(&:key).sort

      assert_equal([5, 10, 15, 20], keys)
    end

    def test_postordered_each_yields_all_keys
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.postordered_each.map(&:key).sort

      assert_equal([5, 10, 15, 20], keys)
    end

    def test_breadth_each_yields_all_keys
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])
      keys = tree.breadth_each.map(&:key).sort

      assert_equal([5, 10, 15, 20], keys)
    end

    def test_height
      tree = build_tree([[1, 'a'], [2, 'b'], [3, 'c']])
      assert_equal(0, tree.height)

      taller = build_tree([[1, 'a'], [2, 'b'], [3, 'c'], [4, 'd']])
      assert_operator(taller.height, :>=, 1)
    end

    def test_to_h_round_trip
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      rebuilt = Tree::BTree.from_hash(tree.to_h)

      assert_equal(tree.to_a, rebuilt.to_a)
    end

    def test_as_json_returns_hash
      tree = build_tree([[10, 'a']])

      assert_kind_of(Hash, tree.as_json)
    end
  end
end
