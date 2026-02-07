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

    def teardown
      @root = nil
    end

    def test_has_version_number
      assert_not_nil(Tree::VERSION)
    end

    def test_root_setup
      assert_detached_node(@root, name: 'ROOT', content_provided: true, content: 'Root Node')
      assert(@root.to_s.include?('Content: Root Node'), 'to_s should include content value')
      assert_raise(ArgumentError) { Tree::TreeNode.new(nil) }
      assert_raise(ArgumentError) { Tree::TreeNode.new('ROOT', nil, :bad) }
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

    def test_name_accessor
      assert_equal 'ROOT', @root.name, "Name should be 'ROOT'"
    end
  end
end
