# test_api_stabilization_contracts.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/binaryheap'
require_relative '../lib/tree/binarymaxheap'
require_relative '../lib/tree/btree'
require_relative '../lib/tree/fenwicktree'
require_relative '../lib/tree/segmenttree'
require_relative '../lib/tree/trie'

module TestTree
  # Stabilization-focused edge-contract tests for public APIs.
  class TestApiStabilizationContracts < Test::Unit::TestCase
    def test_key_value_lookup_alias_error_parity
      aa = Tree::AATree.new
      bt = Tree::BTree.new(2)

      assert_raise(ArgumentError) { aa.search(nil) }
      assert_raise(ArgumentError) { aa.lookup(nil) }
      assert_raise(ArgumentError) { bt.search(nil) }
      assert_raise(ArgumentError) { bt.lookup(nil) }
    end

    def test_aggregate_query_alias_error_parity
      fenwick = Tree::FenwickTree.new(3, [1, 2, 3])
      segment = Tree::SegmentTree.new(3, [1, 2, 3])

      assert_raise(ArgumentError) { fenwick.range_sum(2, 1) }
      assert_raise(ArgumentError) { fenwick.query(2, 1) }
      assert_raise(ArgumentError) { segment.range_sum(2, 1) }
      assert_raise(ArgumentError) { segment.query(2, 1) }
    end

    def test_heap_pop_extract_empty_contract
      min_heap = Tree::BinaryHeapNode.new('root')
      max_heap = Tree::BinaryMaxHeapNode.new('root')

      assert_nil(min_heap.extract)
      assert_nil(min_heap.pop)
      assert_nil(max_heap.extract)
      assert_nil(max_heap.pop)
    end

    def test_trie_search_alias_validation_parity
      trie = Tree::TrieNode.new('')

      assert_raise(ArgumentError) { trie.include?('') }
      assert_raise(ArgumentError) { trie.search('') }
      assert_raise(ArgumentError) { trie.include?(123) }
      assert_raise(ArgumentError) { trie.search(123) }
    end

    def test_comparable_contract_for_array_backed_trees
      fenwick = Tree::FenwickTree.new(2, [1, 2])
      segment = Tree::SegmentTree.new(2, [1, 2])

      assert_nil(fenwick <=> segment)
      assert_nil(segment <=> fenwick)
    end
  end
end
