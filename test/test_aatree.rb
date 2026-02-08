# test_aatree.rb - This file is part of the RubyTree package.
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

module TestTree
  # Test class for the AA tree.
  class TestAATree < Test::Unit::TestCase
    def build_tree(entries)
      Tree::AATree.new(entries)
    end

    def test_insert_keeps_keys_sorted
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c'], [6, 'd'], [12, 'e']])
      assert_equal(tree.keys.sort, tree.keys)
    end

    def test_search
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])

      assert_equal('b', tree.search(20))
      assert_nil(tree.search(7))
    end

    def test_delete
      tree = build_tree([[10, 'a'], [20, 'b'], [5, 'c']])

      assert_equal('c', tree.delete(5))
      assert_nil(tree.search(5))
      assert_equal(tree.keys.sort, tree.keys)
    end

    def test_bracket_access
      tree = build_tree([[10, 'a'], [20, 'b']])

      assert_equal('b', tree[20])
      tree[20] = 'z'
      assert_equal('z', tree.search(20))
    end

    def test_traversals
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c'], [15, 'd']])

      assert_equal([5, 10, 15, 20], tree.preordered_each.map(&:key).sort)
      assert_equal([5, 10, 15, 20], tree.postordered_each.map(&:key).sort)
      assert_equal([5, 10, 15, 20], tree.breadth_each.map(&:key).sort)
    end

    def test_to_h_round_trip
      tree = build_tree([[10, 'a'], [5, 'b'], [20, 'c']])
      rebuilt = Tree::AATree.from_hash(tree.to_h)

      assert_equal(tree.to_a, rebuilt.to_a)
    end

    def test_comparable
      left = build_tree([[10, 'a'], [5, 'b']])
      right = build_tree([[10, 'a'], [5, 'c']])

      assert_equal(-1, left <=> right)
    end

    def test_nil_key_rejected
      tree = build_tree([])
      assert_raise(ArgumentError) { tree.insert(nil, 'a') }
    end
  end
end
