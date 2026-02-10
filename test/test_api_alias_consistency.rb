# test_api_alias_consistency.rb - This file is part of the RubyTree package.
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
  # Alias-consistency tests for Phase 2 API harmonization.
  class TestApiAliasConsistency < Test::Unit::TestCase
    def test_key_value_lookup_alias
      aa = Tree::AATree.new([[10, 'a']])
      bt = Tree::BTree.new(2, [{ key: 10, value: 'a' }])

      assert_equal(aa.search(10), aa.lookup(10))
      assert_equal(bt.search(10), bt.lookup(10))
    end

    def test_aggregate_query_alias
      fenwick = Tree::FenwickTree.new(4, [1, 2, 3, 4])
      segment = Tree::SegmentTree.new(4, [1, 2, 3, 4])

      assert_equal(fenwick.range_sum(1, 3), fenwick.query(1, 3))
      assert_equal(segment.range_sum(1, 3), segment.query(1, 3))
    end

    def test_heap_pop_alias
      min_heap = Tree::BinaryHeapNode.new('root', 3)
      min_heap.insert('a', 1)
      min_heap.insert('b', 2)
      max_heap = Tree::BinaryMaxHeapNode.new('root', 3)
      max_heap.insert('a', 9)
      max_heap.insert('b', 8)

      assert_equal(1, min_heap.pop)
      assert_equal(2, min_heap.extract)
      assert_equal(9, max_heap.pop)
      assert_equal(8, max_heap.extract)
    end

    def test_trie_search_alias
      trie = Tree::TrieNode.new('')
      trie.insert('cat')

      assert_equal(trie.include?('cat'), trie.search('cat'))
      assert_equal(trie.include?('dog'), trie.search('dog'))
    end
  end
end
