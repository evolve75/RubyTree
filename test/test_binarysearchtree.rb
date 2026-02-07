# test_binarysearchtree.rb - This file is part of the RubyTree package.
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
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation and/or
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
require_relative '../lib/tree/binarysearchtree'

module TestTree
  # Test class for the binary search tree node.
  class TestBinarySearchTreeNode < Test::Unit::TestCase
    def inorder_contents(node)
      result = []
      node.inordered_each { |entry| result << entry.content }
      result
    end

    def test_insert_and_inorder
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)
      root.insert('n15', 15)
      root.insert('n12', 12)
      root.insert('n18', 18)
      root.insert('n2', 2)

      assert_equal([2, 5, 10, 12, 15, 18], inorder_contents(root))
    end

    def test_search
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)
      root.insert('n15', 15)

      assert_equal('n15', root.search(15).name)
      assert_nil(root.search(7))
    end

    def test_delete_leaf
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)
      root.insert('n15', 15)
      root.insert('n2', 2)

      removed = root.delete(2)
      assert_equal(2, removed.content)
      assert_equal([5, 10, 15], inorder_contents(root))
    end

    def test_delete_node_with_one_child
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)
      root.insert('n2', 2)

      removed = root.delete(5)
      assert_equal(5, removed.content)
      assert_equal([2, 10], inorder_contents(root))
    end

    def test_delete_node_with_two_children
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)
      root.insert('n15', 15)
      root.insert('n12', 12)
      root.insert('n18', 18)
      root.insert('n2', 2)

      removed = root.delete(15)
      assert_equal(15, removed.content)
      assert_equal([2, 5, 10, 12, 18], inorder_contents(root))
    end

    def test_delete_root_with_single_child
      root = Tree::BinarySearchTreeNode.new('root', 10)
      root.insert('n5', 5)

      removed = root.delete(10)
      assert_equal(10, removed.content)
      assert_equal(5, root.content)
      assert_nil(root.left_child)
      assert_nil(root.right_child)
    end

    def test_delete_root_leaf
      root = Tree::BinarySearchTreeNode.new('root', 10)

      removed = root.delete(10)
      assert_equal(10, removed.content)
      assert_nil(root.content)
    end
  end
end
