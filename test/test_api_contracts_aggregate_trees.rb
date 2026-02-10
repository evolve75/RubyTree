# test_api_contracts_aggregate_trees.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/fenwicktree'
require_relative '../lib/tree/segmenttree'

module TestTree
  # Contract tests for aggregate trees.
  class TestApiContractsAggregateTrees < Test::Unit::TestCase
    def test_fenwick_contract
      tree = Tree::FenwickTree.new(4, [1, 2, 3, 4])

      assert_nil(tree.update(2, 5))
      assert_equal(11, tree.sum(2))
      assert_equal(14, tree.range_sum(1, 3))

      stored = tree.send(:[]=, 0, 2)
      assert_equal(tree[0], stored)
      assert_kind_of(Enumerator, tree.each)
      assert_equal([0, 1, 2, 3], tree.keys)
      assert_equal(false, tree.respond_to?(:<<))
      assert_raise(NoMethodError) { tree << 1 }
    end

    def test_segment_contract
      tree = Tree::SegmentTree.new(4, [1, 2, 3, 4])

      assert_kind_of(Numeric, tree.update(2, 10))
      assert_equal(16, tree.range_sum(1, 3))

      stored = tree.send(:[]=, 0, 8)
      assert_equal(tree[0], stored)
      assert_kind_of(Enumerator, tree.each)
      assert_equal([0, 1, 2, 3], tree.keys)
      assert_equal(false, tree.respond_to?(:<<))
      assert_raise(NoMethodError) { tree << 1 }
    end

    def test_aggregate_tree_serialization_contract
      [Tree::FenwickTree.new(3, [1, 2, 3]), Tree::SegmentTree.new(3, [1, 2, 3])].each do |tree|
        hash = tree.to_h
        rebuilt = tree.class.from_hash(hash)

        assert_equal(tree.to_a, rebuilt.to_a)
        assert_equal(hash, tree.as_json)
        assert_equal(tree.to_a, tree.class.json_create(hash).to_a)
      end
    end

    def test_aggregate_tree_validation_contract
      assert_raise(ArgumentError) { Tree::FenwickTree.new(0) }
      assert_raise(ArgumentError) { Tree::SegmentTree.new(0) }

      fenwick = Tree::FenwickTree.new(2)
      segment = Tree::SegmentTree.new(2)

      assert_raise(ArgumentError) { fenwick.update(0, nil) }
      assert_raise(ArgumentError) { segment.update(0, nil) }
    end
  end
end
