# test_intervaltree.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/intervaltree'

module TestTree
  # Test class for the interval tree node.
  class TestIntervalTreeNode < Test::Unit::TestCase
    def build_tree(intervals)
      root = Tree::IntervalTreeNode.new('root', intervals.first)
      intervals.drop(1).each_with_index do |interval, idx|
        root.insert("n#{idx}", interval)
      end
      root
    end

    def inorder_keys(node)
      result = []
      node.inordered_each { |entry| result << entry.key }
      result
    end

    def max_end_valid?(node)
      return true unless node&.content

      expected = [node.interval_end, node.left_child&.max_end, node.right_child&.max_end].compact.max
      return false unless expected == node.max_end

      max_end_valid?(node.left_child) && max_end_valid?(node.right_child)
    end

    def test_insert_maintains_order_and_max_end
      root = build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40])

      assert_equal(inorder_keys(root).sort, inorder_keys(root))
      assert_equal(true, max_end_valid?(root))
    end

    def test_search_overlaps
      root = build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40])

      results = root.search_overlaps(14..16).map(&:content)
      expected = [15..20, 10..30, 5..20, 12..15]
      assert_equal(expected.sort_by(&:begin), results.sort_by(&:begin))
    end

    def test_search_point
      root = build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40])

      results = root.search_point(17).map(&:content)
      expected = [15..20, 10..30, 17..19, 5..20]
      assert_equal(expected.sort_by(&:begin), results.sort_by(&:begin))
    end

    def test_delete_refreshes_max_end
      root = build_tree([15..20, 10..30, 17..19, 5..20, 12..15, 30..40])

      root.delete(10..30)
      assert_equal(true, max_end_valid?(root))
    end
  end
end
