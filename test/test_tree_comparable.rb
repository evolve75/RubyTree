# test_tree_comparable.rb - This file is part of the RubyTree package.
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
require_relative 'support/fixtures_shared'

module TestTree
  class TestTreeComparable < Test::Unit::TestCase
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

    def test_spaceship
      first_node  = Tree::TreeNode.new(1)
      second_node = Tree::TreeNode.new(2)

      assert_nil(first_node <=> nil)
      assert_equal(-1, first_node <=> second_node)

      second_node = Tree::TreeNode.new(1)
      assert_equal(0, first_node <=> second_node)

      first_node  = Tree::TreeNode.new('ABC')
      second_node = Tree::TreeNode.new('XYZ')

      assert_nil(first_node <=> nil)
      assert_equal(-1, first_node <=> second_node)

      second_node = Tree::TreeNode.new('ABC')
      assert_equal(0, first_node <=> second_node)
    end

    def test_cmp_policies
      setup_test_tree

      assert_equal(-1, @child1.cmp(@child2, policy: :name))
      assert_equal(0, @child1.cmp(@child1, policy: :name))
      assert_nil(@child1.cmp('nope', policy: :name))

      assert_equal(-1, @root.cmp(@child1, policy: :each))
      assert_equal(-1, @child1.cmp(@child2, policy: :each))
      assert_equal(1, @child3.cmp(@child2, policy: :each))

      assert_equal(-1, @root.cmp(@child1, policy: :breadth_each))
      assert_equal(-1, @child1.cmp(@child2, policy: :breadth_each))
      assert_equal(1, @child3.cmp(@child2, policy: :breadth_each))

      assert_equal(-1, @root.cmp(@child4, policy: :direct_only))
      assert_equal(1, @child4.cmp(@root, policy: :direct_only))
      assert_nil(@child1.cmp(@child2, policy: :direct_only))

      assert_equal(-1, @child1.cmp(@child2, policy: :direct_or_sibling))
      assert_equal(1, @child2.cmp(@child1, policy: :direct_or_sibling))
      assert_equal(-1, @root.cmp(@child4, policy: :direct_or_sibling))
      assert_nil(@child1.cmp(@child4, policy: :direct_or_sibling))

      other_root = Tree::TreeNode.new('OTHER')
      assert_nil(@root.cmp(other_root, policy: :each))
      assert_nil(@root.cmp(other_root, policy: :breadth_each))
    end

    def test_is_comparable
      node_a = Tree::TreeNode.new('NodeA', 'Some Content')
      node_b = Tree::TreeNode.new('NodeB', 'Some Content')
      node_c = Tree::TreeNode.new('NodeC', 'Some Content')

      assert(node_a <  node_b, "Node A is lexically 'less than' node B")
      assert(node_a <= node_b, "Node A is lexically 'less than' node B")
      assert(node_b >  node_a, "Node B is lexically 'greater than' node A")
      assert(node_b >= node_a, "Node B is lexically 'greater than' node A")

      assert(node_a != node_b, 'Node A and Node B are not equal')
      assert(node_b.between?(node_a, node_c), 'Node B is lexically between node A and node C')
    end
  end
end
