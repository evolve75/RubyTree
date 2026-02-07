# test_tree_conversion.rb - This file is part of the RubyTree package.
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
require 'json'
require_relative '../lib/tree/tree_deps'
require_relative 'support/fixtures_shared'

module TestTree
  class TestTreeConversion < Test::Unit::TestCase
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

    def test_from_hash
      hash = { [:A, 'Root content'] => {
        B: {
          E: {},
          F: {
            H: {},
            [:I, 'Leaf content'] => {}
          }
        },
        C: {},
        D: {
          G: {}
        }
      } }

      tree = Tree::TreeNode.from_hash(hash)

      assert_same(Tree::TreeNode, tree.class)
      assert_same(tree.name, :A)
      assert_equal(true, tree.root?)
      assert_equal(false, tree.leaf?)
      assert_equal(9, tree.size)
      assert_equal('Root content', tree.content)
      assert_equal(3, tree.children.count)

      leaf_with_content = tree[:B][:F][:I]
      assert_equal('Leaf content', leaf_with_content.content)
      assert_equal(true, leaf_with_content.leaf?)

      leaf_without_content = tree[:C]
      assert_equal(true, leaf_without_content.leaf?)

      interior_node = tree[:B][:F]
      assert_equal(false, interior_node.leaf?)
      assert_equal(2, interior_node.children.count)

      assert_raise(ArgumentError) { Tree::TreeNode.from_hash({}) }
      assert_raise(ArgumentError) { Tree::TreeNode.from_hash({ A: {}, B: {} }) }
    end

    def test_from_hash_with_nils
      hash = { [:A, 'Root content'] => {
        B: {
          E: nil,
          F: {
            H: nil,
            [:I, 'Leaf content'] => nil
          }
        },
        C: nil,
        D: {
          G: nil
        }
      } }

      tree = Tree::TreeNode.from_hash(hash)

      assert_same(Tree::TreeNode, tree.class)
      assert_same(:A, tree.name)
      assert_equal(true, tree.root?)
      assert_equal(false, tree.leaf?)
      assert_equal(9, tree.size)
      assert_equal('Root content', tree.content)
      assert_equal(3, tree.children.count)

      leaf_with_content = tree[:B][:F][:I]
      assert_equal('Leaf content', leaf_with_content.content)
      assert_equal(true, leaf_with_content.leaf?)

      leaf_without_content = tree[:C]
      assert_equal(true, leaf_without_content.leaf?)

      interior_node = tree[:B][:F]
      assert_equal(false, interior_node.leaf?)
      assert_equal(2, interior_node.children.count)
    end

    def test_add_from_hash
      tree = Tree::TreeNode.new(:A)

      hash = {}
      assert_equal([], tree.add_from_hash(hash))

      hash = { B: { C: { D: nil }, E: {}, F: {} }, [:G, 'G content'] => {} }
      added_children = tree.add_from_hash(hash)
      assert_equal(Array, added_children.class)
      assert_equal(2, added_children.count)
      assert_equal(7, tree.size)
      assert_equal('G content', tree[:G].content)
      assert_equal(true, tree[:G].leaf?)
      assert_equal(5, tree[:B].size)
      assert_equal(3, tree[:B].children.count)

      assert_raise(ArgumentError) { tree.add_from_hash([]) }
      assert_raise(ArgumentError) { tree.add_from_hash('not a hash') }
      assert_raise(ArgumentError) { tree.add_from_hash({ X: 'Not a hash or nil' }) }
    end

    def test_to_h
      a = Tree::TreeNode.new(:A)
      b = Tree::TreeNode.new(:B)
      c = Tree::TreeNode.new(:C)
      e = Tree::TreeNode.new(:E)
      f = Tree::TreeNode.new(:F)
      g = Tree::TreeNode.new(:G)

      a << b
      a << c
      c << f
      c << g
      b << e

      exported = a.to_h
      expected = { A: { B: { E: {} }, C: { F: {}, G: {} } } }
      assert_equal(expected, exported)
    end

    def test_to_h_from_hash_symmetry
      input = { A: { B: { E: { I: {}, J: {} }, F: {}, G: {} }, C: { H: { K: {} } } } }
      node = Tree::TreeNode.from_hash(input)
      assert_equal(input, node.to_h)
    end

    def test_marshal_dump
      test_root = Tree::TreeNode.new('ROOT', 'Root Node')
      test_content = { 'KEY1' => 'Value1', 'KEY2' => 'Value2' }
      test_child = Tree::TreeNode.new('Child', test_content)
      test_content2 = %w[AValue1 AValue2 AValue3]
      test_grand_child = Tree::TreeNode.new('Grand Child 1', test_content2)
      test_root << test_child << test_grand_child

      data = Marshal.dump(test_root)
      # rubocop:disable Security/MarshalLoad
      new_root = Marshal.load(data)
      # rubocop:enable Security/MarshalLoad

      assert_equal(test_root.name, new_root.name, 'Must identify as ROOT')
      assert_equal(test_root.content, new_root.content, "Must have root's content")
      assert(new_root.root?, 'Must be the ROOT node')
      assert(new_root.children?, 'Must have a child node')

      new_child = new_root[test_child.name]
      assert_equal(test_child.name, new_child.name, 'Must have child 1')
      assert(new_child.content?, 'Child must have content')
      assert(new_child.only_child?, 'Child must be the only child')

      new_child_content = new_child.content
      assert_equal(Hash, new_child_content.class, "Class of child's content should be a hash")
      assert_equal(test_child.content.size, new_child_content.size, 'The content should have same size')

      new_grand_child = new_child[test_grand_child.name]
      assert_equal(test_grand_child.name, new_grand_child.name, 'Must have grand child')
      assert(new_grand_child.content?, 'Grand-child must have content')
      assert(new_grand_child.only_child?, 'Grand-child must be the only child')

      new_grand_child_content = new_grand_child.content
      assert_equal(Array, new_grand_child_content.class, "Class of grand-child's content should be an Array")
      assert_equal(test_grand_child.content.size, new_grand_child_content.size, 'The content should have same size')
    end

    alias test_marshal_load test_marshal_dump

    def test_json_serialization
      setup_test_tree

      expected_json = {
        'name' => 'ROOT',
        'content' => 'Root Node',
        JSON.create_id => 'Tree::TreeNode',
        'children' => [
          { 'name' => 'Child1', 'content' => 'Child Node 1', JSON.create_id => 'Tree::TreeNode' },
          { 'name' => 'Child2', 'content' => 'Child Node 2', JSON.create_id => 'Tree::TreeNode' },
          {
            'name' => 'Child3',
            'content' => 'Child Node 3',
            JSON.create_id => 'Tree::TreeNode',
            'children' => [
              { 'name' => 'Child4', 'content' => 'Grand Child 1', JSON.create_id => 'Tree::TreeNode' }
            ]
          }
        ]
      }.to_json

      assert_equal(expected_json, @root.to_json)
    end

    def test_json_deserialization
      tree_as_json = {
        'name' => 'ROOT',
        'content' => 'Root Node',
        JSON.create_id => 'Tree::TreeNode',
        'children' => [
          { 'name' => 'Child1', 'content' => 'Child Node 1', JSON.create_id => 'Tree::TreeNode' },
          { 'name' => 'Child2', 'content' => 'Child Node 2', JSON.create_id => 'Tree::TreeNode' },
          {
            'name' => 'Child3',
            'content' => 'Child Node 3',
            JSON.create_id => 'Tree::TreeNode',
            'children' => [
              { 'name' => 'Child4', 'content' => 'Grand Child 1', JSON.create_id => 'Tree::TreeNode' }
            ]
          }
        ]
      }.to_json

      tree = JSON.parse(tree_as_json, create_additions: true)

      assert_equal(@root.name, tree.root.name, 'Root should be returned')
      assert_equal(@child1.name, tree[0].name, 'Child 1 should be returned')
      assert_equal(@child2.name, tree[1].name, 'Child 2 should be returned')
      assert_equal(@child3.name, tree[2].name, 'Child 3 should be returned')
      assert_equal(@child4.name, tree[2][0].name, 'Grand Child 1 should be returned')
    end

    def test_json_round_trip
      root_node = Tree::TreeNode.new('ROOT', 'Root Content')
      root_node << Tree::TreeNode.new('CHILD1',
                                      'Child1 Content') << Tree::TreeNode.new('GRAND_CHILD1', 'GrandChild1 Content')
      root_node << Tree::TreeNode.new('CHILD2', 'Child2 Content')

      j = root_node.to_json

      k = JSON.parse(j, create_additions: true)

      assert_equal(k.name, root_node.name, 'Root should be returned')
      assert_equal(k[0].name, root_node[0].name, 'Child 1 should be returned')
      assert_equal(k[0][0].name, root_node[0][0].name, 'Grand Child 1 should be returned')
      assert_equal(k[1].name, root_node[1].name, 'Child 2 should be returned')
    end
  end
end
