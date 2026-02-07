# test_tree_traversal.rb - This file is part of the RubyTree package.
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
require 'stringio'
require_relative '../lib/tree/tree_deps'
require_relative 'support/fixtures_shared'

module TestTree
  class TestTreeTraversal < Test::Unit::TestCase
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

    def test_each
      setup_test_tree

      assert(@root.children?, 'Should have children')
      assert_equal(5, @root.size, 'Should have five nodes')
      assert(@child3.children?, 'Should have children')

      nodes = @root.map { |node| node }

      assert_equal(5, nodes.length, 'Should have FIVE NODES')
      assert(nodes.include?(@root), 'Should have root')
      assert(nodes.include?(@child1), 'Should have child 1')
      assert(nodes.include?(@child2), 'Should have child 2')
      assert(nodes.include?(@child3), 'Should have child 3')
      assert(nodes.include?(@child4), 'Should have child 4')
    end

    def test_each_leaf
      setup_test_tree

      result_array = []
      result = @root.each_leaf { |node| result_array << node }
      assert_equal(@root, result)
      assert_equal(3, result_array.length, 'Should have THREE LEAF NODES')
      assert(!result_array.include?(@root), 'Should not have root')
      assert(result_array.include?(@child1), 'Should have child 1')
      assert(result_array.include?(@child2), 'Should have child 2')
      assert(!result_array.include?(@child3), 'Should not have child 3')
      assert(result_array.include?(@child4), 'Should have child 4')

      result_array.clear
      result_array = @root.each_leaf
      assert_equal(Array, result_array.class)
      assert_equal(3, result_array.length, 'Should have THREE LEAF NODES')
      assert(!result_array.include?(@root), 'Should not have root')
      assert(result_array.include?(@child1), 'Should have child 1')
      assert(result_array.include?(@child2), 'Should have child 2')
      assert(!result_array.include?(@child3), 'Should not have child 3')
      assert(result_array.include?(@child4), 'Should have child 4')
    end

    def test_each_level
      setup_test_tree

      levels = @root.each_level.to_a

      assert_equal(3, levels.length, 'Should have three levels')
      assert_equal([@root], levels[0])
      assert_equal([@child1, @child2, @child3], levels[1])
      assert_equal([@child4], levels[2])

      assert_equal(Enumerator, @root.each_level.class) if defined?(Enumerator.class)
      assert_equal(Enumerable::Enumerator, @root.each_level.class) \
        if defined?(Enumerable::Enumerator.class)
    end

    def test_find
      setup_test_tree
      found_node = @root.find { |node| node == @child2 }
      assert_same(@child2, found_node, 'The node should be Child 2')

      found_node = @root.find { |node| node == @child4 }
      assert_same(@child4, found_node, 'The node should be Child 4')

      found_node = @root.find { |node| node.name == 'Child4' }
      assert_same(@child4, found_node, 'The node should be Child 4')
      found_node = @root.find { |node| node.name == 'NOT PRESENT' }
      assert_nil(found_node, 'The node should not be found')
    end

    def test_breadth_each
      j = Tree::TreeNode.new('j')
      f = Tree::TreeNode.new('f')
      k = Tree::TreeNode.new('k')
      a = Tree::TreeNode.new('a')
      d = Tree::TreeNode.new('d')
      h = Tree::TreeNode.new('h')
      z = Tree::TreeNode.new('z')

      expected_array = [j,
                        f, k,
                        a, h, z,
                        d]

      j << f << a << d
      f << h
      j << k << z

      result_array = []
      result = j.breadth_each { |node| result_array << node.detached_copy }

      assert_equal(j, result)

      expected_array.each_index do |i|
        assert_equal(expected_array[i].name, result_array[i].name)
      end

      assert_equal(Enumerator, j.breadth_each.class) if defined?(Enumerator.class)
      assert_equal(Enumerable::Enumerator, j.breadth_each.class) if defined?(Enumerable::Enumerator.class)

      result_array = j.breadth_each.collect { |node| node }
      expected_array.each_index do |i|
        assert_equal(expected_array[i].name, result_array[i].name)
      end
    end

    def test_preordered_each
      j = Tree::TreeNode.new('j')
      f = Tree::TreeNode.new('f')
      k = Tree::TreeNode.new('k')
      a = Tree::TreeNode.new('a')
      d = Tree::TreeNode.new('d')
      h = Tree::TreeNode.new('h')
      z = Tree::TreeNode.new('z')

      expected_array = [j, f, a, d, h, k, z]

      j << f << a << d
      f << h
      j << k << z

      result_array = []
      result = j.preordered_each { |node| result_array << node.detached_copy }

      assert_equal(j, result)

      expected_array.each_index do |i|
        assert_equal(expected_array[i].name, result_array[i].name)
      end

      assert_equal(Enumerator, j.preordered_each.class) \
        if defined?(Enumerator.class)

      assert_equal(Enumerable::Enumerator, j.preordered_each.class) \
        if defined?(Enumerable::Enumerator.class)
    end

    def test_postordered_each
      j = Tree::TreeNode.new('j')
      f = Tree::TreeNode.new('f')
      k = Tree::TreeNode.new('k')
      a = Tree::TreeNode.new('a')
      d = Tree::TreeNode.new('d')
      h = Tree::TreeNode.new('h')
      z = Tree::TreeNode.new('z')

      expected_array = [d, a, h, f, z, k, j]

      j << f << a << d
      f << h
      j << k << z

      result_array = []
      result = j.postordered_each { |node| result_array << node.detached_copy }

      assert_equal(j, result)

      expected_array.each_index do |i|
        assert_equal(expected_array[i].name, result_array[i].name)
      end

      assert_equal(Enumerator, j.postordered_each.class) if defined?(Enumerator.class)
      assert_equal(Enumerable::Enumerator, j.postordered_each.class) \
        if defined?(Enumerable::Enumerator.class)

      result_array = j.postordered_each.collect { |node| node }

      expected_array.each_index do |i|
        assert_equal(expected_array[i].name, result_array[i].name)
      end
    end

    def test_collect
      setup_test_tree
      collect_array = @root.collect do |node|
        node.content = 'abc'
        node
      end
      collect_array.each { |node| assert_equal('abc', node.content, "Should be 'abc'") }
    end

    def test_print_tree
      setup_test_tree
      buffer = StringIO.new
      @root.print_tree(0, nil, nil, io: buffer)
      assert(buffer.string.include?('ROOT'))
    end

    def test_print_tree_to_s
      setup_test_tree
      output = @root.print_tree_to_s
      assert(output.include?('ROOT'))
    end
  end
end
