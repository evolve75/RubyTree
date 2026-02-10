# test_api_contracts_ordered_node_trees.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/avltree'
require_relative '../lib/tree/binarysearchtree'
require_relative '../lib/tree/intervaltree'
require_relative '../lib/tree/orderstatistictree'
require_relative '../lib/tree/redblacktree'
require_relative '../lib/tree/splaytree'
require_relative '../lib/tree/treap'

module TestTree
  # Contract tests for ordered node trees.
  class TestApiContractsOrderedNodeTrees < Test::Unit::TestCase
    def test_core_insert_search_delete_contract_for_bst_family
      trees = [
        Tree::BinarySearchTreeNode.new('root', 10),
        Tree::AvlTreeNode.new('root', 10),
        Tree::RedBlackTreeNode.new('root', 10),
        Tree::SplayTreeNode.new('root', 10),
        Tree::TreapNode.new('root', 10),
        Tree::OrderStatisticTreeNode.new('root', 10)
      ]

      trees.each do |root|
        inserted = root.insert('n5', 5)
        assert_kind_of(root.class, inserted)

        inserted_with_add = root.add(root.class.new('n12', 12))
        assert_kind_of(root.class, inserted_with_add)

        found = root.search(5)
        assert_kind_of(root.class, found)
        assert_equal(5, found.content)

        removed = root.delete(5)
        assert_kind_of(root.class, removed)
        assert_equal(5, removed.content)
        assert_nil(root.search(5))
      end
    end

    def test_bst_family_min_max_key_contract
      trees = [
        Tree::BinarySearchTreeNode.new('root', 10),
        Tree::AvlTreeNode.new('root', 10),
        Tree::RedBlackTreeNode.new('root', 10),
        Tree::SplayTreeNode.new('root', 10),
        Tree::TreapNode.new('root', 10)
      ]

      trees.each do |root|
        root.insert('n5', 5)
        root.insert('n20', 20)
        tree_root = root.root

        assert_equal(10, root.key)
        assert_equal(5, tree_root.min_node.content)
        assert_equal(20, tree_root.max_node.content)
      end
    end

    def test_order_statistic_rank_and_select_contract
      root = Tree::OrderStatisticTreeNode.new('root', 10)
      [5, 20, 15].each_with_index do |value, index|
        root.insert("n#{index}", value)
      end

      assert_equal(0, root.rank(5))
      assert_equal(2, root.rank(15))
      assert_equal(20, root.select(3).content)
      assert_nil(root.select(-1))
    end

    def test_interval_tree_contract
      root = Tree::IntervalTreeNode.new('root', 10..20)
      inserted = root.insert('a', 15..25)

      assert_kind_of(Tree::IntervalTreeNode, inserted)
      assert_equal([10, 20], root.key)
      assert_equal(10, root.interval_start)
      assert_equal(20, root.interval_end)
      assert_kind_of(Array, root.search_overlaps(18..19))
      assert_kind_of(Array, root.search_point(16))

      found = root.search(10..20)
      assert_kind_of(Tree::IntervalTreeNode, found)

      removed = root.delete(15..25)
      assert_kind_of(Tree::IntervalTreeNode, removed)
      assert_nil(root.search(15..25))
    end

    def test_ordered_node_trees_raise_on_nil_key_where_applicable
      trees = [
        Tree::BinarySearchTreeNode.new('root', 10),
        Tree::AvlTreeNode.new('root', 10),
        Tree::RedBlackTreeNode.new('root', 10),
        Tree::SplayTreeNode.new('root', 10),
        Tree::TreapNode.new('root', 10),
        Tree::OrderStatisticTreeNode.new('root', 10)
      ]

      trees.each do |root|
        assert_raise(ArgumentError) { root.search(nil) }
      end
    end
  end
end
