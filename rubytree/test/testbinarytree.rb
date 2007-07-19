#!/usr/bin/env ruby

# testtree.rb
#
# $Revision$ by $Author$
# $Name$
#
# Copyright (c) 2006, 2007 Anupam Sengupta
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
require 'tree/binarytree'
require 'person'

# Test class for the Tree node.
class TC_BinaryTreeTest < Test::Unit::TestCase

  def setup
    @root = Tree::BinaryTreeNode.new("ROOT", "Root Node")

    @left_child1  = Tree::BinaryTreeNode.new("A Child at Left", "Child Node @ left")
    @right_child1 = Tree::BinaryTreeNode.new("B Child at right", "Child Node @ right")

  end

  def teardown
    @root.remove!(@left_child1)
    @root.remove!(@right_child1)
    @root = nil
  end

  def test_initialize
    assert_not_nil(@root, "Binary tree's Root should have been created")
  end

  def test_add
    @root.add  @left_child1
    assert_same(@left_child1, @root.leftChild, "The left node should be left_child1")
    assert_same(@left_child1, @root.firstChild, "The first node should be left_child1")

    @root.add @right_child1
    assert_same(@right_child1, @root.rightChild, "The right node should be right_child1")
    assert_same(@right_child1, @root.lastChild, "The first node should be right_child1")

    assert_raise RuntimeError do
      @root.add Tree::BinaryTreeNode.new("The third child!")
    end

    assert_raise RuntimeError do
      @root << Tree::BinaryTreeNode.new("The third child!")
    end
  end

  def test_left
    @root << @left_child1
    @root << @right_child1
    assert_same(@left_child1, @root.leftChild, "The left child should be 'left_child1")
    assert_not_same(@right_child1, @root.leftChild, "The right_child1 is not the left child")
  end

  def test_right
    @root << @left_child1
    @root << @right_child1
    assert_same(@right_child1, @root.rightChild, "The right child should be 'right_child1")
    assert_not_same(@left_child1, @root.rightChild, "The left_child1 is not the left child")
  end

  def test_left_assignment
    @root << @left_child1
    @root << @right_child1
    assert_same(@left_child1, @root.leftChild, "The left child should be 'left_child1")

    @root.leftChild = Tree::BinaryTreeNode.new("New Left Child")
    assert_equal("New Left Child", @root.leftChild.name, "The left child should now be the new child")
  end

  def test_right_assignment
    @root << @left_child1
    @root << @right_child1
    assert_same(@right_child1, @root.rightChild, "The right child should be 'right_child1")

    @root.rightChild = Tree::BinaryTreeNode.new("New Right Child")
    assert_equal("New Right Child", @root.rightChild.name, "The right child should now be the new child")
  end

  def test_isLeftChild?
    @root << @left_child1
    @root << @right_child1

    assert(@left_child1.isLeftChild?, "left_child1 should be the left child")
    assert(!@right_child1.isLeftChild?, "left_child1 should be the left child")

    assert(!@root,isLeftChild?, "Root is neither left child nor right")
  end

  def test_isRightChild?
    @root << @left_child1
    @root << @right_child1

    assert(@right_child1.isRightChild?, "right_child1 should be the right child")
    assert(!@left_child1.isRightChild?, "right_child1 should be the right child")
    assert(!@root,isRightChild?, "Root is neither left child nor right")
  end
end

# $Log$
# Revision 1.3  2007/07/19 02:02:12  anupamsg
# Removed useless files (including rdoc, which should be generated for each release.
#
# Revision 1.2  2007/07/18 20:15:06  anupamsg
# Added two predicate methods in BinaryTreeNode to determine whether a node
# is a left or a right node.
#
