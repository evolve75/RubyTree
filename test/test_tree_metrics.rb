# test_tree_metrics.rb - This file is part of the RubyTree package.
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
  class TestTreeMetrics < Test::Unit::TestCase
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

    def test_size
      assert_equal(1, @root.size, "Root's size should be 1")
      setup_test_tree

      assert_equal(5, @root.size, "Root's size should be 5")
      assert_equal(2, @child3.size, "Child 3's size should be 2")
    end

    def test_node_height
      assert_equal(0, @root.node_height, "A single node's height is 0")

      @root << @child1
      assert_equal(1, @root.node_height, 'This should be of height 1')
      assert_equal(0, @child1.node_height, 'This should be of height 0')

      @root << @child2
      assert_equal(1, @root.node_height, 'This should be of height 1')
      assert_equal(0, @child2.node_height, 'This should be of height 0')

      @child2 << @child3
      assert_equal(2, @root.node_height, 'This should be of height 2')
      assert_equal(1, @child2.node_height, 'This should be of height 1')
      assert_equal(0, @child3.node_height, 'This should be of height 0')

      @child3 << @child4
      assert_equal(3, @root.node_height, 'This should be of height 3')
      assert_equal(2, @child2.node_height, 'This should be of height 2')
      assert_equal(1, @child3.node_height, 'This should be of height 1')
      assert_equal(0, @child4.node_height, 'This should be of height 0')
    end

    def test_node_depth
      assert_equal(0, @root.node_depth, "A root node's depth is 0")

      setup_test_tree

      [@child1, @child2, @child3].each do |child|
        assert_equal(1, child.node_depth, "Node #{child.name} should have depth 1")
      end

      assert_equal(2, @child4.node_depth, 'Child 4 should have depth 2')

      @root << @child5 << @child3
      assert_equal(3, @child4.node_depth, 'Child 4 should have depth 3 after Child 5 inserted above')
    end

    def test_level
      assert_equal(0, @root.level, "A root node's level is 0")

      assert_equal(@root.node_depth, @root.level, 'Level and depth should be the same')

      setup_test_tree
      [@child1, @child2, @child3].each do |child|
        assert_equal(1, child.level, "Node #{child.name} should have level 1")
        assert_equal(@root.node_depth, @root.level, 'Level and depth should be the same')
      end

      assert_equal(2, @child4.level, 'Child 4 should have level 2')
    end

    def test_breadth
      assert_equal(1, @root.breadth, "A single node's breadth is 1")

      @root << @child1
      assert_equal(1, @root.breadth, 'This should be of breadth 1')

      @root << @child2
      assert_equal(2, @child1.breadth, 'This should be of breadth 2')
      assert_equal(2, @child2.breadth, 'This should be of breadth 2')

      @root << @child3
      assert_equal(3, @child1.breadth, 'This should be of breadth 3')
      assert_equal(3, @child2.breadth, 'This should be of breadth 3')

      @child3 << @child4
      assert_equal(1, @child4.breadth, 'This should be of breadth 1')
    end

    def test_in_degree
      setup_test_tree

      assert_equal(0, @root.in_degree, "Root's in-degree should be zero")
      assert_equal(1, @child1.in_degree, "Child 1's in-degree should be 1")
      assert_equal(1, @child2.in_degree, "Child 2's in-degree should be 1")
      assert_equal(1, @child3.in_degree, "Child 3's in-degree should be 1")
      assert_equal(1, @child4.in_degree, "Child 4's in-degree should be 1")
    end

    def test_out_degree
      setup_test_tree

      assert_equal(3, @root.out_degree, "Root's out-degree should be 3")
      assert_equal(0, @child1.out_degree, "Child 1's out-degree should be 0")
      assert_equal(0, @child2.out_degree, "Child 2's out-degree should be 0")
      assert_equal(1, @child3.out_degree, "Child 3's out-degree should be 1")
      assert_equal(0, @child4.out_degree, "Child 4's out-degree should be 0")
    end
  end
end
