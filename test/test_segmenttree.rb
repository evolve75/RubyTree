# test_segmenttree.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/segmenttree'

module TestTree
  # Test class for the segment tree.
  class TestSegmentTree < Test::Unit::TestCase
    def build_tree(values)
      Tree::SegmentTree.new(values.length, values)
    end

    def test_initialize_applies_values
      tree = build_tree([1, 2, 3])

      assert_equal(6, tree.range_sum(0, 2))
    end

    def test_initialize_rejects_invalid_size
      assert_raise(ArgumentError) { Tree::SegmentTree.new(0) }
    end

    def test_update_adjusts_range
      tree = build_tree([1, 2, 3, 4])
      tree.update(2, 10)

      assert_equal(16, tree.range_sum(1, 3))
    end

    def test_range_sum
      tree = build_tree([1, 2, 3, 4, 5])

      assert_equal(9, tree.range_sum(1, 3))
    end

    def test_index_accessor
      tree = build_tree([1, 2, 3, 4, 5])

      assert_equal(5, tree[4])
    end

    def test_index_writer_sets_value
      tree = build_tree([1, 2, 3])
      tree[1] = 5

      assert_equal(5, tree[1])
    end

    def test_each_yields_values
      tree = build_tree([3, 1, 4])

      assert_equal([3, 1, 4], tree.each.to_a)
    end

    def test_keys
      tree = build_tree([1, 2, 3])

      assert_equal([0, 1, 2], tree.keys)
    end

    def test_values
      tree = build_tree([2, 4, 6])

      assert_equal([2, 4, 6], tree.values)
    end

    def test_to_h_round_trip
      tree = build_tree([1, 3, 5])
      copy = Tree::SegmentTree.from_hash(tree.to_h)

      assert_equal([1, 3, 5], copy.to_a)
    end

    def test_as_json
      tree = build_tree([1, 2])

      assert_equal(tree.to_h, tree.as_json)
    end

    def test_comparable
      left = build_tree([1, 2, 3])
      right = build_tree([1, 2, 4])

      assert_equal(-1, left <=> right)
    end
  end
end
