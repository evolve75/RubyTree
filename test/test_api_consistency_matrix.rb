# test_api_consistency_matrix.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/aatree'
require_relative '../lib/tree/avltree'
require_relative '../lib/tree/binaryheap'
require_relative '../lib/tree/binarymaxheap'
require_relative '../lib/tree/binarysearchtree'
require_relative '../lib/tree/btree'
require_relative '../lib/tree/fenwicktree'
require_relative '../lib/tree/intervaltree'
require_relative '../lib/tree/orderstatistictree'
require_relative '../lib/tree/redblacktree'
require_relative '../lib/tree/segmenttree'
require_relative '../lib/tree/splaytree'
require_relative '../lib/tree/treap'
require_relative '../lib/tree/trie'

module TestTree
  # API consistency guardrails by semantic family.
  class TestApiConsistencyMatrix < Test::Unit::TestCase
    def test_ordered_node_tree_method_surface
      required = %i[insert add search delete key]

      [
        Tree::BinarySearchTreeNode.new('root', 10),
        Tree::AvlTreeNode.new('root', 10),
        Tree::RedBlackTreeNode.new('root', 10),
        Tree::SplayTreeNode.new('root', 10),
        Tree::TreapNode.new('root', 10),
        Tree::OrderStatisticTreeNode.new('root', 10),
        Tree::IntervalTreeNode.new('root', 10..20)
      ].each do |tree|
        assert_methods_present(tree, required)
      end
    end

    def test_heap_tree_method_surface
      required = %i[insert add peek extract search delete key]

      [
        Tree::BinaryHeapNode.new('root', 10),
        Tree::BinaryMaxHeapNode.new('root', 10)
      ].each do |tree|
        assert_methods_present(tree, required)
      end
    end

    def test_key_value_tree_method_surface
      required = %i[
        insert << search delete [] []= size length each keys values to_a to_h
        as_json to_json <=>
      ]
      class_methods = %i[from_hash json_create]

      [Tree::AATree.new, Tree::BTree.new].each do |tree|
        assert_methods_present(tree, required)
        assert_methods_present(tree.class, class_methods)
      end
    end

    def test_aggregate_tree_method_surface
      required = %i[
        length each update range_sum [] []= keys values to_a to_h as_json
        to_json <=>
      ]
      class_methods = %i[from_hash json_create]

      [Tree::FenwickTree.new(3), Tree::SegmentTree.new(3)].each do |tree|
        assert_methods_present(tree, required)
        assert_methods_present(tree.class, class_methods)
      end

      assert_equal(true, Tree::FenwickTree.new(3).respond_to?(:sum))
      assert_equal(true, Tree::SegmentTree.new(3).respond_to?(:sum))
    end

    def test_trie_method_surface
      trie = Tree::TrieNode.new('')
      required = %i[
        insert << include? prefix? delete delete? words_with_prefix terminal?
      ]

      assert_methods_present(trie, required)
    end

    def test_intentionally_absent_shovel_for_array_backed_trees
      assert_equal(false, Tree::FenwickTree.new(3).respond_to?(:<<))
      assert_equal(false, Tree::SegmentTree.new(3).respond_to?(:<<))
    end

    private

    def assert_methods_present(target, methods)
      methods.each do |method_name|
        assert_equal(
          true,
          target.respond_to?(method_name),
          "Expected #{target.class} to respond to ##{method_name}"
        )
      end
    end
  end
end
