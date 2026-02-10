# test_api_contracts_key_value_trees.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/btree'

module TestTree
  # Contract tests for key/value trees.
  class TestApiContractsKeyValueTrees < Test::Unit::TestCase
    def test_aa_tree_contract
      tree = Tree::AATree.new
      inserted = tree.insert(10, 'a')
      assert_equal(10, inserted.key)

      tree << [5, 'b']
      assert_equal('b', tree.search(5))
      assert_equal('b', tree[5])

      assigned = (tree[5] = 'bb')
      assert_equal('bb', assigned)
      assert_equal('bb', tree.search(5))

      removed = tree.delete(10)
      assert_equal('a', removed)
      assert_nil(tree.search(10))

      assert_kind_of(Enumerator, tree.each)
    end

    def test_b_tree_contract
      tree = Tree::BTree.new(2)
      inserted = tree.insert(10, 'a')
      assert_equal(10, inserted.key)

      tree << [5, 'b']
      assert_equal('b', tree.search(5))
      assert_equal('b', tree[5])

      assigned = (tree[5] = 'bb')
      assert_equal('bb', assigned)
      assert_equal('bb', tree.search(5))

      removed = tree.delete(10)
      assert_equal('a', removed)
      assert_nil(tree.search(10))

      assert_kind_of(Enumerator, tree.each)
    end

    def test_key_value_tree_serialization_contract
      [Tree::AATree.new([[10, 'a']]), Tree::BTree.new(2, [{ key: 10, value: 'a' }])].each do |tree|
        hash = tree.to_h
        rebuilt = tree.class.from_hash(hash)

        assert_equal(tree.to_a, rebuilt.to_a)
        assert_equal(hash, tree.as_json)
        assert_equal(tree.to_a, tree.class.json_create(hash).to_a)
      end
    end

    def test_key_value_tree_nil_key_rejected
      assert_raise(ArgumentError) { Tree::AATree.new.insert(nil, 'x') }
      assert_raise(ArgumentError) { Tree::BTree.new.insert(nil, 'x') }
    end
  end
end
