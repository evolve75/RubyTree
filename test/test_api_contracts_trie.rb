# test_api_contracts_trie.rb - This file is part of the RubyTree package.
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
require_relative '../lib/tree/trie'

module TestTree
  # Contract tests for trie API.
  class TestApiContractsTrie < Test::Unit::TestCase
    def build_trie(words)
      root = Tree::TrieNode.new('')
      words.each { |word| root.insert(word) }
      root
    end

    def test_insert_and_membership_contract
      trie = build_trie(%w[cat car cart])

      assert_equal(true, trie.include?('cat'))
      assert_equal(true, trie.prefix?('ca'))
      assert_equal(false, trie.include?('cab'))

      terminal = trie << 'cape'
      assert_kind_of(Tree::TrieNode, terminal)
      assert_equal(true, terminal.terminal?)
      assert_equal(true, trie.include?('cape'))
    end

    def test_delete_and_delete_alias_contract
      trie = build_trie(%w[cat car cart])

      assert_equal(true, trie.delete('cart'))
      assert_equal(false, trie.include?('cart'))
      assert_equal(true, trie.include?('car'))

      assert_equal(true, trie.delete?('car'))
      assert_equal(false, trie.include?('car'))
      assert_equal(false, trie.delete('car'))
      assert_equal(false, trie.delete?('car'))
    end

    def test_words_with_prefix_and_validation_contract
      trie = build_trie(%w[cat car cart dog])

      assert_equal(%w[car cart cat], trie.words_with_prefix('ca').sort)
      limited = trie.words_with_prefix('ca', limit: 1)
      assert_equal(1, limited.size)
      assert_equal(true, %w[car cart cat].include?(limited.first))

      assert_raise(ArgumentError) { trie.insert('') }
      assert_raise(ArgumentError) { trie.include?('') }
      assert_raise(ArgumentError) { trie.prefix?(123) }
    end
  end
end
