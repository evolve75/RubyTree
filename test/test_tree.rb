# test_tree.rb - This file is part of the RubyTree package.
#
# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
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
require_relative 'support/assertions'

module TestTree
  class TestTreeNode < Test::Unit::TestCase
    include TreeTestFixtures
    include TreeTestAssertions

    Person = Struct.new(:first_name, :last_name)

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

    def teardown
      @root = nil
    end

    def test_has_version_number
      assert_not_nil(Tree::VERSION)
    end

    def test_root_setup
      assert_detached_node(@root, name: 'ROOT', content_provided: true, content: 'Root Node')
      assert(@root.to_s.include?('Content: Root Node'), 'to_s should include content value')
      assert(!@root.children?, 'Cannot have any children')
      assert(@root.content?, 'This root should have content')
      assert_equal(1, @root.size, 'Number of nodes should be one')
      assert_equal(0, @root.siblings.length, 'This root does not have any children')
      assert_equal(0, @root.in_degree, 'Root should have an in-degree of 0')
      assert_equal(0, @root.node_height, "Root's height before adding any children is 0")
      assert_raise(ArgumentError) { Tree::TreeNode.new(nil) }
    end

    def test_root
      setup_test_tree

      assert_same(@root, @root.root, "Root's root is self")
      assert_same(@root, @child1.root, 'Root should be ROOT')
      assert_same(@root, @child4.root, 'Root should be ROOT')
      assert_equal(2, @root.node_height, "Root's height after adding the children should be 2")
    end

    def test_to_s_empty_content
      empty = Tree::TreeNode.new('EMPTY')
      assert_match(/Content: <Empty>/, empty.to_s)
    end

    def test_has_content_eh
      a_node = Tree::TreeNode.new('A Node')
      assert_nil(a_node.content, 'The node should not have content')
      assert(!a_node.content?, 'The node should not have content')

      a_node.content = 'Something'
      assert_not_nil(a_node.content, 'The node should now have content')
      assert(a_node.content?, 'The node should now have content')
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

    def test_to_s
      a_node = Tree::TreeNode.new('A Node', 'Some Content')

      expected_string = 'Node Name: A Node Content: Some Content Parent: <None> Children: 0 Total Nodes: 1'

      assert_equal(expected_string, a_node.to_s, 'The string representation should be same')

      a_node = Tree::TreeNode.new(:Node_Name, 'Some Content')
      expected_string = 'Node Name: Node_Name Content: Some Content Parent: <None> Children: 0 Total Nodes: 1'
      assert_equal(expected_string, a_node.to_s, 'The string representation should be same')

      a_node = Tree::TreeNode.new(:Node_Name, :Content)
      expected_string = 'Node Name: Node_Name Content: Content Parent: <None> Children: 0 Total Nodes: 1'
      assert_equal(expected_string, a_node.to_s, 'The string representation should be same')

      a_hash = { a_key: 'Some Value' }
      a_node = Tree::TreeNode.new(:Node_Name, a_hash)
      expected_string = "Node Name: Node_Name Content: #{a_hash} Parent: <None> Children: 0 Total Nodes: 1"
      assert_equal(expected_string, a_node.to_s, 'The string representation should be same')

      child_node = Tree::TreeNode.new(:Child_node, 'Child Node')
      a_node << child_node

      expected_string = 'Node Name: Child_node Content: Child Node Parent: Node_Name Children: 0 Total Nodes: 1'
      assert_equal(expected_string, child_node.to_s, 'The string representation should be same')
    end

    def test_content
      person = Person.new('John', 'Doe')
      @root.content = person
      assert_same(person, @root.content, 'Content should be the same')
    end

    def test_content_equals
      @root.content = nil
      assert_nil(@root.content, "Root's content should be nil")
      @root.content = 'dummy content'
      assert_equal('dummy content', @root.content, "Root's content should now be 'dummy content'")
    end

    def test_is_root_eh
      setup_test_tree
      assert(@root.root?, 'The ROOT node must respond as the root node')
    end

    def test_is_leaf_eh
      setup_test_tree
      assert(!@child3.leaf?, 'Child 3 is not a leaf node')
      assert(@child4.leaf?, 'Child 4 is a leaf node')
    end

    def test_name_accessor
      setup_test_tree

      assert_equal 'ROOT', @root.name, "Name should be 'ROOT'"
    end

    def test_integer_node_names
      @n_root = Tree::TreeNode.new(0, 'Root Node')
      @n_child1 = Tree::TreeNode.new(1, 'Child Node 1')
      @n_child2 = Tree::TreeNode.new(2, 'Child Node 2')
      @n_child3 = Tree::TreeNode.new('three', 'Child Node 3')

      @n_root << @n_child1
      @n_root << @n_child2
      @n_root << @n_child3

      assert_not_equal(@n_root[1].name, 1)
      assert_equal(@n_root[0].name, '1')
      assert_equal(@n_root[1].name, '2')

      assert_equal(@n_root['three'].name, 'three')
    end

    def test_add_node_to_self_as_child
      root = Tree::TreeNode.new('root')

      assert_raise(ArgumentError) { root << root }

      child = Tree::TreeNode.new('child')
      assert_raise(ArgumentError) { root << child << root }
    end

    def test_single_node_becomes_leaf
      setup_test_tree

      leafs = @root.each_leaf
      parents = leafs.collect(&:parent)
      leafs.each(&:remove_from_parent!)
      parents.each do |parent|
        assert(parent.leaf?) unless parent.children?
      end
    end

    def test_unique_node_names
      setup_test_tree

      assert_raise(RuntimeError) { @root << @child1 }

      begin
        @root.first_child << @child2
      rescue RuntimeError => e
        raise("No error #{e} should have been raised for adding a non-sibling duplicate.")
      end
    end

    def test_indexed_access
      setup_test_tree

      assert_equal(@child1, @root[0], 'Should be the first child')
      assert_equal(@child4, @root[2][0], 'Should be the grandchild')
      assert_nil(@root['TEST'], 'Should be nil')
      assert_nil(@root[99], 'Should be nil')
      assert_raise(ArgumentError) { @root[nil] }
    end

    def test_index
      assert_raise(ArgumentError) { @root[nil] }

      @root << @child1
      @root << @child2
      assert_equal(@child1.name, @root['Child1'].name, 'Child 1 should be returned')
      assert_equal(@child1.name, @root[0].name, 'Child 1 should be returned')
      assert_equal(@child1.name, @root[-2].name, 'Child 1 should be returned')
      assert_equal(@child1.name,
                   @root[-@root.children.size].name, 'Child 1 should be returned')

      assert_equal(@child2.name, @root['Child2'].name, 'Child 2 should be returned')
      assert_equal(@child2.name, @root[1].name, 'Child 2 should be returned')
      assert_equal(@child2.name, @root[-1].name, 'Child 2 should be returned')

      assert_nil(@root['Some Random Name'], 'Should return nil')
      assert_nil(@root[99], 'Should return nil')
      assert_nil(@root[-(@root.children.size + 1)], 'Should return nil')
      assert_nil(@root[-3], 'Should return nil')
    end
  end
end
