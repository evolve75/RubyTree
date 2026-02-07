# test_tree_structure.rb - This file is part of the RubyTree package.
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
require_relative 'support/assertions'

module TestTree
  class TestTreeStructure < Test::Unit::TestCase
    include TreeTestFixtures
    include TreeTestAssertions

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

    def test_add
      assert(!@root.children?, 'Should not have any children')

      assert_equal(1, @root.size, 'Should have 1 node (the root)')
      @root.add(@child1)

      @root << @child2

      assert(@root.children?, 'Should have children')
      assert_equal(3, @root.size, 'Should have three nodes')

      @root << @child3 << @child4

      assert_equal(5, @root.size, 'Should have five nodes')
      assert_equal(2, @child3.size, 'Should have two nodes')

      assert_raise(ArgumentError) { @root.add(nil) }

      error = assert_raise(ArgumentError) { @child4.add(@child3) }
      assert_match(/Attempting add ancestor as a child/, error.message)
    end

    def test_add_duplicate
      root = Tree::TreeNode.new('root')
      one  = Tree::TreeNode.new('one')
      two  = Tree::TreeNode.new('two')
      three = Tree::TreeNode.new('three')
      deep = Tree::TreeNode.new('deep')

      root << one << deep
      assert_raise(RuntimeError) { root.add(Tree::TreeNode.new(one.name)) }
      assert_raise(RuntimeError) { root.add(one) }

      begin
        root << two << deep
      rescue RuntimeError => e
        raise("Error! The RuntimeError #{e} should not have been thrown. " \
              'The same node can be added to different branches.')
      end

      assert_raise(ArgumentError) { root << three << three }

      root.remove_all!
      begin
        three_dup = Tree::TreeNode.new('three')
        root << three << three_dup
      rescue RuntimeError => e
        raise("Error! The RuntimeError #{e} should not have been thrown. The same node name can be used in the branch.")
      end
    end

    def test_add_node_to_self_as_child
      root = Tree::TreeNode.new('root')

      assert_raise(ArgumentError) { root << root }

      child = Tree::TreeNode.new('child')
      assert_raise(ArgumentError) { root << child << root }
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

    def test_add_at_specific_position
      assert(!@root.children?, 'Should not have any children')

      assert_equal(1, @root.size, 'Should have 1 node (the root)')
      @root.add(@child1)
      assert_equal(@child1, @root[0])

      @root << @child2
      assert_equal(@child1, @root[0])
      assert_equal(@child2, @root[1])
      assert_equal(2, @root.children.size, 'Should have two child nodes')

      @root.add(@child3, 1)
      assert_equal(@child1, @root[0])
      assert_equal(@child3, @root[1])
      assert_equal(@child2, @root[2])
      assert_equal(3, @root.children.size, 'Should have three child nodes')

      @root.add(@child4, @root.children.size)
      assert_equal(@child1, @root[0])
      assert_equal(@child3, @root[1])
      assert_equal(@child2, @root[2])
      assert_equal(@child4, @root[3])
      assert_equal(4, @root.children.size, 'Should have four child nodes')

      assert_raise(RuntimeError) do
        @root.add(@child5, @root.children.size + 1)
      end
      assert_equal(@child1, @root[0])
      assert_equal(@child3, @root[1])
      assert_equal(@child2, @root[2])
      assert_equal(@child4, @root[3])
      assert_nil(@root[4])
      assert_equal(4, @root.children.size, 'Should have four child nodes')

      assert_raise(RuntimeError) do
        @root.add(@child5, -(@root.children.size + 2))
      end
      assert_nil(@root[-5])
      assert_equal(@child1, @root[-4])
      assert_equal(@child3, @root[-3])
      assert_equal(@child2, @root[-2])
      assert_equal(@child4, @root[-1])
      assert_equal(4, @root.children.size, 'Should have four child nodes')

      @root.add(@child5, -(@root.children.size + 1))
      assert_nil(@root[-6])
      assert_equal(@child5, @root[-5])
      assert_equal(@child1, @root[-4])
      assert_equal(@child3, @root[-3])
      assert_equal(@child2, @root[-2])
      assert_equal(@child4, @root[-1])
      assert_equal(5, @root.children.size, 'Should have five child nodes')
    end

    def test_replace_bang
      @root << @child1
      @root << @child2
      @root << @child3

      assert_equal(4, @root.size, 'Should have four nodes')
      assert(@root.children.include?(@child1), 'Should parent child1')
      assert(@root.children.include?(@child2), 'Should parent child2')
      assert(@root.children.include?(@child3), 'Should parent child3')
      assert(!@root.children.include?(@child4), 'Should not parent child4')

      @root.replace!(@child2, @child4)

      @root.replace! @child4, @child4.detached_copy

      assert_equal(4, @root.size, 'Should have three nodes')
      assert(@root.children.include?(@child1), 'Should parent child1')
      assert(!@root.children.include?(@child2), 'Should not parent child2')
      assert(@root.children.include?(@child3), 'Should parent child3')
      assert(@root.children.include?(@child4), 'Should parent child4')
      assert_equal(1, @root.children.find_index(@child4), 'Should add child4 to index 1')
    end

    def test_replace_with
      @root << @child1
      @root << @child2

      assert_equal(3, @root.size, 'Should have three nodes')
      assert(@root.children.include?(@child1), 'Should parent child1')
      assert(@root.children.include?(@child2), 'Should parent child2')
      assert(!@root.children.include?(@child3), 'Should not parent child3')

      @child2.replace_with @child3

      assert_equal(3, @root.size, 'Should have three nodes')
      assert(@root.children.include?(@child1), 'Should parent child1')
      assert(!@root.children.include?(@child2), 'Should not parent child2')
      assert(@root.children.include?(@child3), 'Should parent child3')
    end

    def test_remove_bang
      @root << @child1
      @root << @child2

      assert(@root.children?, 'Should have children')
      assert_equal(3, @root.size, 'Should have three nodes')

      @root.remove!(@child1)
      assert_equal(2, @root.size, 'Should have two nodes')
      @root.remove!(@child2)

      assert(!@root.children?, 'Should have no children')
      assert_equal(1, @root.size, 'Should have one node')

      @root << @child1
      @root << @child2

      assert(@root.children?, 'Should have children')
      assert_equal(3, @root.size, 'Should have three nodes')

      @root.remove_all!

      assert(!@root.children?, 'Should have no children')
      assert_equal(1, @root.size, 'Should have one node')

      @root.remove!(nil)
      assert(!@root.children?, 'Should have no children')
      assert_equal(1, @root.size, 'Should have one node')
    end

    def test_remove_all_bang
      setup_test_tree
      assert(@root.children?, 'Should have children')
      @root.remove_all!

      assert(!@root.children?, 'Should have no children')
      assert_equal(1, @root.size, 'Should have one node')

      assert(@child1.root?, 'Child1 should be a root after remove_all!')
      assert(@child2.root?, 'Child2 should be a root after remove_all!')
      assert(@child3.root?, 'Child3 should be a root after remove_all!')
      assert(@child4.root?, 'Child4 should be a root after remove_all!')
      assert_nil(@child1.parent, 'Child1 parent should be nil after remove_all!')
      assert_nil(@child2.parent, 'Child2 parent should be nil after remove_all!')
      assert_nil(@child3.parent, 'Child3 parent should be nil after remove_all!')
      assert_nil(@child4.parent, 'Child4 parent should be nil after remove_all!')
    end

    def test_remove_from_parent_bang
      setup_test_tree

      assert(@root.children?, 'Should have children')
      assert(!@root.leaf?, 'Root is not a leaf here')

      child1 = @root[0]
      assert_not_nil(child1, 'Child 1 should exist')
      assert_same(@root, child1.root, "Child 1's root should be ROOT")
      assert(@root.include?(child1), 'root should have child1')
      child1.remove_from_parent!
      assert_same(child1, child1.root, "Child 1's root should be self")
      assert(!@root.include?(child1), 'root should not have child1')

      child1.remove_from_parent!
      assert_same(child1, child1.root, "Child 1's root should still be self")
    end

    def test_detached_copy
      setup_test_tree

      assert(@root.children?, 'The root should have children')
      copy_of_root = @root.detached_copy
      assert(!copy_of_root.children?, 'The copy should not have children')
      assert_clone_of(@root, copy_of_root)

      assert(!@child3.root?, 'Child 3 is not a root')
      assert(@child3.children?, 'Child 3 has children')
      copy_of_child3 = @child3.detached_copy
      assert(copy_of_child3.root?, "Child 3's copy is a root")
      assert(!copy_of_child3.children?, "Child 3's copy does not have children")
      assert_clone_of(@child3, copy_of_child3)
    end

    def test_detached_subtree_copy
      setup_test_tree

      assert(@root.children?, 'The root should have children.')
      tree_copy = @root.detached_subtree_copy

      assert_equal(@root.name, tree_copy.name, 'The names should be equal.')
      assert_not_equal(@root.object_id, tree_copy.object_id, 'Object_ids should differ.')
      assert(tree_copy.root?, 'Copied root should be a root node.')
      assert(tree_copy.children?, 'Copied tree should have children.')
      assert_equal(tree_copy.children.count, @root.children.count,
                   'Copied tree and the original tree should have same number of children.')

      assert_equal(tree_copy[0].name, @child1.name, 'The names of Child1 (original and copy) should be same.')
      assert_not_equal(tree_copy[0].object_id, @child1.object_id,
                       'Child1 Object_ids (original and copy) should differ.')
      assert(!tree_copy[0].root?, 'Child1 copied should not be root.')
      assert(!tree_copy[0].children?, 'Child1 copied should not have children.')

      assert_equal(tree_copy[1].name, @child2.name, 'The names of Child2 (original and copy) should be same.')
      assert_not_equal(tree_copy[1].object_id, @child2.object_id,
                       'Child2 Object_ids (original and copy) should differ.')
      assert(!tree_copy[1].root?, 'Child2 copied should not be root.')
      assert(!tree_copy[1].children?, 'Child2 copied should not have children.')

      assert_equal(tree_copy[2].name, @child3.name, 'The names of Child3 (original and copy) should be same.')
      assert_not_equal(tree_copy[2].object_id, @child3.object_id,
                       'Child3 Object_ids (original and copy) should differ.')
      assert(!tree_copy[2].root?, 'Child3 copied should not be root.')
      assert(tree_copy[2].children?, 'Child3 copied should have children.')

      assert_equal(tree_copy[2][0].name, @child4.name, 'The names of Child4 (original and copy) should be same.')
      assert_not_equal(tree_copy[2][0].object_id, @child4.object_id,
                       'Child4 Object_ids (original and copy) should differ.')
      assert(!tree_copy[2][0].root?, 'Child4 copied should not be root.')
      assert(!tree_copy[2][0].children?, 'Child4 copied should not have children.')
    end

    def test_freeze_tree_bang
      setup_test_tree

      @root.content = 'ABC'
      assert_equal('ABC', @root.content, "Content should be 'ABC'")
      @root.freeze_tree!
      require 'rubygems'
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.5')
        assert_raise(RuntimeError, TypeError) { @root.content = '123' }
        assert_raise(RuntimeError, TypeError) { @root[0].content = '123' }
      else
        assert_raise(FrozenError) { @root.content = '123' }
        assert_raise(FrozenError) { @root[0].content = '123' }
      end
    end

    def test_lt2
      @root << @child1
      @root << @child2
      @root << @child3 << @child4
      assert_not_nil(@root['Child1'], 'Child 1 should have been added to Root')
      assert_not_nil(@root['Child2'], 'Child 2 should have been added to Root')
      assert_not_nil(@root['Child3'], 'Child 3 should have been added to Root')
      assert_not_nil(@child3['Child4'], 'Child 4 should have been added to Child3')
    end

    def test_rename
      setup_test_tree

      @root.rename 'ALT_ROOT'
      assert_equal('ALT_ROOT', @root.name, "Name should be 'ALT_ROOT'")

      @child1.rename 'ALT_Child1'
      assert_equal('ALT_Child1', @child1.name, "Name should be 'ALT_Child1'")
      assert_equal(@child1, @root['ALT_Child1'], 'Should be able to access from parent using new name')
    end

    def test_rename_child
      setup_test_tree

      assert_raise(ArgumentError) { @root.rename_child('Not_Present_Child1', 'ALT_Child1') }

      error = assert_raise(ArgumentError) { @root.rename_child('Child1', 'Child2') }
      assert_match(/Child name already exists: Child2/, error.message)

      @root.rename_child('Child1', 'ALT_Child1')
      assert_equal('ALT_Child1', @child1.name, "Name should be 'ALT_Child1'")
      assert_equal(@child1, @root['ALT_Child1'], 'Should be able to access from parent using new name')
    end

    def test_change_parent
      root_node = Tree::TreeNode.new('OLD_ROOT')

      child_node = Tree::TreeNode.new('CHILD')
      assert_equal(0, child_node.node_depth)

      root_node << child_node
      assert_equal(root_node['CHILD'].name, 'CHILD')
      assert_equal(0, root_node.node_depth)
      assert_equal(1, child_node.node_depth)

      grandchild_node = Tree::TreeNode.new('GRANDCHILD')
      child_node << grandchild_node
      assert_equal(root_node['CHILD']['GRANDCHILD'].name, 'GRANDCHILD')
      assert_equal(0, root_node.node_depth)
      assert_equal(1, child_node.node_depth)
      assert_equal(2, grandchild_node.node_depth)

      root2_node = Tree::TreeNode.new('NEW_ROOT')
      assert_equal(0, root2_node.node_depth)

      root2_node << grandchild_node
      assert_equal(root2_node['GRANDCHILD'].name, 'GRANDCHILD')
      assert_equal(root2_node, grandchild_node.parent)
      assert_equal(1, grandchild_node.node_depth)

      root1 = Tree::TreeNode.new('1')
      root1 << Tree::TreeNode.new('2') << Tree::TreeNode.new('4')
      root1 << Tree::TreeNode.new('3') << Tree::TreeNode.new('5')
      root1['3'] << Tree::TreeNode.new('6')
      assert_equal(root1['3']['6'].name, '6')

      root2 = root1.dup
      assert_equal(root1, root2)
      assert_not_same(root1, root2)

      root2['3'] << root1['2']['4']
      assert_equal('3', root2['3']['4'].parent.name)
      assert_nil(root1['2']['4'])
    end

    def test_validate_acyclic
      setup_test_tree

      assert_equal(@root, @root.validate_acyclic!)
      assert(@root.acyclic?, 'Expected the tree to be acyclic')
    end

    def test_validate_acyclic_detects_cycle
      node_a = Tree::TreeNode.new('A')
      node_b = Tree::TreeNode.new('B')

      node_a.instance_variable_set(:@children, [node_b])
      node_a.instance_variable_set(:@children_hash, { node_b.name => node_b })
      node_b.instance_variable_set(:@parent, node_a)

      node_b.instance_variable_set(:@children, [node_a])
      node_b.instance_variable_set(:@children_hash, { node_a.name => node_a })
      node_a.instance_variable_set(:@parent, node_b)

      error = assert_raise(ArgumentError) { node_a.validate_acyclic! }
      assert_match(/Cycle detected/, error.message)
      assert_equal(false, node_a.acyclic?)
    end
  end
end
