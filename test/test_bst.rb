#!/usr/bin/env ruby

# test_bst.rb - This file is part of the RubyTree package.
#
# $Revision$ by $Author$ on $Date$
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010 Anupam Sengupta
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

require 'test/unit'
require 'tree/bst'

module TestTree
  # Test class for the binary search tree node.
  class TestBSTNode < Test::Unit::TestCase

    # Setup the test data scaffolding.
    def setup
      @root = Tree::BSTNode.new("B", "Node B")

      @node_A  = Tree::BSTNode.new("A", "Node A")
      @node_C = Tree::BSTNode.new("C", "Node C")
    end

    # Tear down the test data scaffolding.
    def teardown
      @root.remove!(@node_A)
      @root.remove!(@node_C)
      @root = nil
    end

    # Test initialization of the binary tree.
    def test_initialize
      assert_not_nil(@root, "Binary tree's Root should have been created")
      assert_nil(@root.left_child, "The initial left child of root should be nil")
      assert_nil(@root.right_child, "The initial right child of root should be nil")
      assert_equal(@root.children.size, 0, "Initially no children should be present")
      assert_equal(@root.size, 1, "Only 1 node (the root) should be present")
      assert_equal(@root.name, "B", "The root's name should be B")
    end

    # Test the add method.
    def test_add
      @root.add @node_A
      assert(!@node_A.is_root?, "Node A cannot be a root after addition to the ROOT node")

      assert_same(@node_A, @root.left_child, "Node A should be the left child")
      assert_same(@node_A, @root.first_child, "The first node should be node A")
      assert_nil(@root.right_child, "The right child should be nil")
      assert_equal(@root.children.size, 1, "Only one child should be present")

      @root.add @node_C
      assert(!@node_C.is_root?, "Node C cannot be a root after addition to the ROOT node")

      assert_same(@node_C, @root.right_child, "Node C should be right child")
      assert_same(@node_C, @root.last_child, "The last node should be node C")
      assert_equal(@root.children.size, 2, "Both children should be present")

      assert_raise ArgumentError do
        @root.add Tree::BSTNode.new("The third child!")
      end

      assert_raise ArgumentError do
        @root << Tree::BSTNode.new("The third child!")
      end
    end

    def test_add_out_of_sequence
      # Now lets try some out of order additions
      @root.remove_all!
      assert_equal(@root.children.size, 0, "No children should be present")
      assert_equal(@root.size, 1, "Only 1 node (the root) should be present")

      @root.add @node_C

      assert(!@node_C.is_root?, "Node C cannot be a root after addition to the ROOT node")

      assert_same(@node_C, @root.right_child, "Node C should be right child")
      assert_same(@node_C, @root.last_child, "The last node should be node C")
      assert_nil(@root.left_child, "The left child should be nil")
      assert_equal(@root.children.size, 2, "Both child nodes should be present (left_child will be nil)")
      assert_equal(@root.size, 2, "Only 2 nodes (the root B and the right child C) should be present")

      @root.add @node_A
      assert(!@node_A.is_root?, "Node A cannot be a root after addition to the ROOT node")

      assert_same(@node_A, @root.left_child, "Node A should be the left child")
      assert_same(@node_A, @root.first_child, "The first node should be node A")
      assert_equal(@root.children.size, 2, "Both children should be present")
      assert_equal(@root.size, 3, "All 3 nodes (the root and the two child nodes) should be present")

    end

    # Test the left_child method.
    def test_left_child
      @root << @node_C
      @root << @node_A
      assert_same(@node_A, @root.left_child, "The left child should be left_child1")
      assert_not_same(@node_A, @root.right_child, "Node A is not the right child")
      assert_not_same(@node_C, @root.left_child, "The right_child1 is not the left child")
    end

    # Test the right_child method.
    def test_right_child
      @root << @node_C
      @root << @node_A
      assert_same(@node_C, @root.right_child, "The right child should be right_child1")
      assert_not_same(@node_C, @root.left_child, "Node C is not the left child")
      assert_not_same(@node_A, @root.right_child, "The left_child1 is not the left child")
    end

    # Test left_child= method.
    def test_left_child_equals
      @root << @node_A
      @root << @node_C
      assert_same(@node_A, @root.left_child, "The left child should be left_child1")
      assert(!@node_A.is_root?, "The left child now cannot be a root.")

      # Lets try replacing the left node with a ordinally lower node.
      @root.left_child = Tree::BSTNode.new("0")
      assert(!@root.left_child.is_root?, "The left child now cannot be a root.")
      assert_equal("0", @root.left_child.name, "The left child should now be the node 0")
      assert_equal("C", @root.right_child.name, "The right child should remain as node C")

      # Lets try replacing the left node with a ordinally higher node.
      assert_raise ArgumentError do
        @root.left_child = Tree::BSTNode.new("D")
      end
      assert_equal("0", @root.left_child.name, "The left child should remain as node 0")
      assert_equal("C", @root.right_child.name, "The right child should remain as node C")

      # Now set the left child as nil, and retest
      @root.left_child = nil
      assert_nil(@root.left_child, "The left child should now be nil")
      assert_nil(@root.first_child, "The first child is now nil")
      assert_equal("C", @root.right_child.name, "The right child should remain as node C")
    end

    # Test right_child= method.
    def test_right_child_equals
      @root << @node_A
      @root << @node_C
      assert_same(@node_C, @root.right_child, "The right child should be right_child1")
      assert(!@node_C.is_root?, "The right child now cannot be a root.")

      # Lets try replacing the right node with a ordinally higher node.
      @root.right_child = Tree::BSTNode.new("D")
      assert(!@root.right_child.is_root?, "The right child now cannot be a root.")
      assert_equal("D", @root.right_child.name, "The right child should now be node D")
      assert_equal("A", @root.left_child.name, "The left child should remain as node A")
      assert_equal("D", @root.last_child.name, "The last child should now be node D")

      # Now set the right child as nil, and retest
      @root.right_child = nil
      assert_nil(@root.right_child, "The right child should now be nil")
      assert_equal("A", @root.left_child.name, "The left child should remain as node A")
      assert_nil(@root.last_child, "The last child is now nil")
    end

    # Test isLeft_child? method.
    def test_is_left_child_eh
      @root << @node_A
      @root << @node_C

      assert(@node_A.is_left_child?, "left_child1 should be the left child")
      assert(!@node_C.is_left_child?, "left_child1 should be the left child")

      # Now set the right child as nil, and retest
      @root.right_child = nil
      assert(@node_A.is_left_child?, "left_child1 should be the left child")

      assert(!@root.is_left_child?, "Root is neither left child nor right")
    end

    # Test is_right_child? method.
    def test_is_right_child_eh
      @root << @node_A
      @root << @node_C

      assert(@node_C.is_right_child?, "right_child1 should be the right child")
      assert(!@node_A.is_right_child?, "right_child1 should be the right child")

      # Now set the left child as nil, and retest
      @root.left_child = nil
      assert(@node_C.is_right_child?, "right_child1 should be the right child")
      assert(!@root.is_right_child?, "Root is neither left child nor right")
    end

    # Test swap_children method.
    def test_swap_children
      @root << @node_A
      @root << @node_C

      assert_raise RuntimeError do
        @root.swap_children
      end
    end

  end
end
