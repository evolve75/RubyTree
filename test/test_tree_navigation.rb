# test_tree_navigation.rb - This file is part of the RubyTree package.
#
# Copyright (c) 2026 Anupam Sengupta. All rights reserved.
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
require_relative '../lib/tree/tree_deps'
require_relative '../lib/tree/binarytree'
require_relative 'support/fixtures_shared'

module TestTree
  class TestTreeNavigation < Test::Unit::TestCase
    include TreeTestFixtures

    def setup
      nodes = build_basic_tree_nodes
      @root = nodes[:root]
      @child1 = nodes[:child1]
      @child2 = nodes[:child2]
      @child3 = nodes[:child3]
      @child4 = nodes[:child4]
      @child5 = nodes[:child5]
    end

    def setup_test_tree
      attach_basic_tree(
        root: @root,
        child1: @child1,
        child2: @child2,
        child3: @child3,
        child4: @child4,
        child5: @child5
      )
    end

    def test_root
      setup_test_tree

      assert_same(@root, @root.root, "Root's root is self")
      assert_same(@root, @child1.root, 'Root should be ROOT')
      assert_same(@root, @child4.root, 'Root should be ROOT')
    end

    def test_is_root_eh
      setup_test_tree

      assert(@root.root?, 'The ROOT node must respond as the root node')
      assert(!@child1.root?, 'Child 1 is not a root node')
    end

    def test_children
      setup_test_tree

      assert(@root.children?, 'Should have children')
      assert_equal(5, @root.size, 'Should have five nodes')
      assert(@child3.children?, 'Should have children')
      assert(!@child3.leaf?, 'Should not be a leaf')

      assert_equal(1, @child3.node_height, 'The subtree at Child 3 should have a height of 1')
      [@child1, @child2, @child4].each do |child|
        assert_equal(0, child.node_height, "The subtree at #{child.name} should have a height of 0")
      end

      result_array = @root.children

      assert_equal(3, result_array.length, 'Should have three direct children')
      assert(!result_array.include?(@root), 'Should not have root')
      assert_equal(result_array[0], @child1, 'Should have child 1')
      assert_equal(result_array[1], @child2, 'Should have child 2')
      assert_equal(result_array[2], @child3, 'Should have child 3')
      assert(!result_array.include?(@child4), 'Should not have child 4')

      result_array.clear
      result = @root.children { |child| result_array << child }
      assert_equal(@root, result)
      assert_equal(3, result_array.length, 'Should have three children')
      assert_equal(result_array[0], @child1, 'Should have child 1')
      assert_equal(result_array[1], @child2, 'Should have child 2')
      assert_equal(result_array[2], @child3, 'Should have child 3')
      assert(!result_array.include?(@child4), 'Should not have child 4')
    end

    def test_children_compact
      setup_test_tree

      compact_children = @root.children_compact
      assert_equal(3, compact_children.length, 'Should have three direct children')
      assert_equal([@child1, @child2, @child3], compact_children)

      result_array = []
      result = @root.children_compact { |child| result_array << child }
      assert_equal(@root, result)
      assert_equal([@child1, @child2, @child3], result_array)
    end

    def test_children_compact_with_sparse_binary_tree
      root = Tree::BinaryTreeNode.new('Root')
      right_child = Tree::BinaryTreeNode.new('Right')

      root.right_child = right_child

      raw_children = root.children
      assert_equal(2, raw_children.length, 'Binary tree should have two child slots')
      assert_nil(raw_children.first, 'Left child slot should be nil')
      assert_equal(right_child, raw_children.last, 'Right child should be present')

      compact_children = root.children_compact
      assert_equal([right_child], compact_children)
    end

    def test_first_child
      setup_test_tree

      assert_equal(@child1, @root.first_child, "Root's first child is Child1")
      assert_nil(@child1.first_child, 'Child1 does not have any children')
      assert_equal(@child4, @child3.first_child, "Child3's first child is Child4")
    end

    def test_last_child
      setup_test_tree

      assert_equal(@child3, @root.last_child, "Root's last child is Child3")
      assert_nil(@child1.last_child, 'Child1 does not have any children')
      assert_equal(@child4, @child3.last_child, "Child3's last child is Child4")
    end

    def test_first_sibling
      setup_test_tree

      assert_same(@root, @root.first_sibling, "Root's first sibling is itself")
      assert_same(@child1, @child1.first_sibling, "Child1's first sibling is itself")
      assert_same(@child1, @child2.first_sibling, "Child2's first sibling should be child1")
      assert_same(@child1, @child3.first_sibling, "Child3's first sibling should be child1")
      assert_same(@child4, @child4.first_sibling, "Child4's first sibling should be itself")
      assert_not_same(@child1, @child4.first_sibling, "Child4's first sibling is itself")
    end

    def test_is_first_sibling_eh
      setup_test_tree

      assert(@root.first_sibling?, "Root's first sibling is itself")
      assert(@child1.first_sibling?, "Child1's first sibling is itself")
      assert(!@child2.first_sibling?, 'Child2 is not the first sibling')
      assert(!@child3.first_sibling?, 'Child3 is not the first sibling')
      assert(@child4.first_sibling?, "Child4's first sibling is itself")
    end

    def test_is_last_sibling_eh
      setup_test_tree

      assert(@root.last_sibling?, "Root's last sibling is itself")
      assert(!@child1.last_sibling?, 'Child1 is not the last sibling')
      assert(!@child2.last_sibling?, 'Child2 is not the last sibling')
      assert(@child3.last_sibling?, "Child3's last sibling is itself")
      assert(@child4.last_sibling?, "Child4's last sibling is itself")
    end

    def test_last_sibling
      setup_test_tree

      assert_same(@root, @root.last_sibling, "Root's last sibling is itself")
      assert_same(@child3, @child1.last_sibling, "Child1's last sibling should be child3")
      assert_same(@child3, @child2.last_sibling, "Child2's last sibling should be child3")
      assert_same(@child3, @child3.last_sibling, "Child3's last sibling should be itself")
      assert_same(@child4, @child4.last_sibling, "Child4's last sibling should be itself")
      assert_not_same(@child3, @child4.last_sibling, "Child4's last sibling is itself")
    end

    def test_siblings
      setup_test_tree

      siblings = []
      result = @child1.siblings { |sibling| siblings << sibling }

      assert_equal(@child1, result)
      assert_equal(2, siblings.length, 'Should have two siblings')
      assert(siblings.include?(@child2), 'Should have 2nd child as sibling')
      assert(siblings.include?(@child3), 'Should have 3rd child as sibling')

      siblings.clear
      siblings = @child1.siblings
      assert_equal(Array, siblings.class)
      assert_equal(2, siblings.length, 'Should have two siblings')

      siblings.clear
      @child4.siblings { |sibling| siblings << sibling }
      assert(siblings.empty?, 'Should not have any siblings')

      siblings.clear
      siblings = @root.siblings
      assert_equal(0, siblings.length, 'Root should not have any siblings')
    end

    def test_is_only_child_eh
      setup_test_tree

      assert(@root.only_child?, 'Root is an only child')
      assert(!@child1.only_child?, 'Child1 is not the only child')
      assert(!@child2.only_child?, 'Child2 is not the only child')
      assert(!@child3.only_child?, 'Child3 is not the only child')
      assert(@child4.only_child?, 'Child4 is an only child')
    end

    def test_next_sibling
      setup_test_tree

      assert_nil(@root.next_sibling, 'Root does not have any next sibling')
      assert_equal(@child2, @child1.next_sibling, "Child1's next sibling is Child2")
      assert_equal(@child3, @child2.next_sibling, "Child2's next sibling is Child3")
      assert_nil(@child3.next_sibling, 'Child3 does not have a next sibling')
      assert_nil(@child4.next_sibling, 'Child4 does not have a next sibling')
    end

    def test_previous_sibling
      setup_test_tree

      assert_nil(@root.previous_sibling, 'Root does not have any previous sibling')
      assert_nil(@child1.previous_sibling, 'Child1 does not have previous sibling')
      assert_equal(@child1, @child2.previous_sibling, "Child2's previous sibling is Child1")
      assert_equal(@child2, @child3.previous_sibling, "Child3's previous sibling is Child2")
      assert_nil(@child4.previous_sibling, 'Child4 does not have a previous sibling')
    end

    def test_parentage
      setup_test_tree

      assert_nil(@root.parentage, 'Root does not have any parentage')
      assert_equal([@root], @child1.parentage, 'Child1 has Root as its parent')
      assert_equal([@child3, @root], @child4.parentage, 'Child4 has Child3 and Root as ancestors')
    end

    def test_parent
      setup_test_tree

      assert_nil(@root.parent, "Root's parent should be nil")
      assert_equal(@root, @child1.parent, 'Parent should be root')
      assert_equal(@root, @child3.parent, 'Parent should be root')
      assert_equal(@child3, @child4.parent, 'Parent should be child3')
      assert_equal(@root, @child4.parent.parent, 'Parent should be root')
    end

    def test_has_children_eh
      setup_test_tree
      assert(@root.children?, 'The Root node MUST have children')
    end
  end
end
