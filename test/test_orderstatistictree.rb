# test_orderstatistictree.rb - This file is part of the RubyTree package.
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
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/tree/orderstatistictree'

module TestTree
  # Test class for the order-statistic tree node.
  class TestOrderStatisticTreeNode < Test::Unit::TestCase
    def build_tree(values)
      root = Tree::OrderStatisticTreeNode.new('root', values.first)
      values.drop(1).each_with_index do |value, idx|
        root.insert("n#{idx}", value)
      end
      root
    end

    def subtree_size_valid?(node)
      return true unless node&.content

      return false unless subtree_size_matches?(node)
      return false unless subtree_size_valid?(node.left_child)

      subtree_size_valid?(node.right_child)
    end

    def subtree_size_matches?(node)
      left_size = node.left_child&.subtree_size || 0
      right_size = node.right_child&.subtree_size || 0
      (left_size + right_size + 1) == node.subtree_size
    end

    def test_insert_maintains_subtree_sizes
      root = build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1])

      assert_equal(true, subtree_size_valid?(root))
    end

    def test_rank
      root = build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1])

      assert_equal(0, root.rank(1))
      assert_equal(5, root.rank(10))
      assert_equal(8, root.rank(18))
      assert_nil(root.rank(7))
    end

    def test_select
      root = build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1])

      assert_equal(1, root.select(0).content)
      assert_equal(8, root.select(4).content)
      assert_equal(10, root.select(5).content)
      assert_equal(18, root.select(8).content)
      assert_nil(root.select(9))
    end

    def test_delete_refreshes_subtree_sizes
      root = build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1])

      root.delete(12)
      assert_equal(true, subtree_size_valid?(root))
    end
  end
end
