# test_tree_merge.rb - This file is part of the RubyTree package.
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
  class TestTreeMerge < Test::Unit::TestCase
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

    def setup_other_test_tree
      @other_tree = @root.detached_copy
      @other_tree << @child1.detached_copy
      @other_tree['Child1'] << Tree::TreeNode.new('Child1a', 'GrandChild Node 1a')
      @other_tree['Child1'] << Tree::TreeNode.new('Child1b', 'GrandChild Node 1b')
      @other_tree << @child3.detached_copy
      @other_tree['Child3'] << Tree::TreeNode.new('Child3a', 'GrandChild Node 3a')
      @other_tree['Child3']['Child3a'] << Tree::TreeNode.new('Child3a1', 'GreatGrandChild Node 3a1')

      @other_tree2 = Tree::TreeNode.new('ROOT2', 'A different root')
      @other_tree2 << Tree::TreeNode.new('new_child1', 'New Child 1')
    end

    def test_merge
      setup_test_tree
      setup_other_test_tree

      merged_tree = @root.merge(@other_tree)

      assert(@root['Child1']['Child1a'].nil?, '.merge() has altered self.')
      assert(@root['Child1']['Child1b'].nil?, '.merge() has altered self.')
      assert(@root['Child3']['Child3a'].nil?, '.merge() has altered self.')
      assert(merged_tree.is_a?(Tree::TreeNode))
      assert(!merged_tree['Child1']['Child1a'].nil?,
             ".merge() has not included ['Child1']['Child1a'] from other_tree.")
      assert(!merged_tree['Child1']['Child1b'].nil?,
             ".merge() has not included ['Child1']['Child1b'] from other_tree.")
      assert(!merged_tree['Child3']['Child3a'].nil?,
             ".merge() has not included ['Child3']['Child3a'] from other_tree.")
      assert(!merged_tree['Child2'].nil?, ".merge() has not included ['Child2'] from self.")
      assert(!merged_tree['Child3']['Child3a']['Child3a1'].nil?,
             ".merge() has not included ['Child3']['Child3a']['Child3a1'] from other_tree.")
      assert(!merged_tree['Child3']['Child4'].nil?, ".merge() has not included ['Child3']['Child4'] from self.")

      assert_raise(ArgumentError) { @root.merge(@other_tree2) }
      assert_raise(TypeError) { @root.merge('ROOT') }
    end

    def test_merge_bang
      setup_test_tree
      setup_other_test_tree

      @root.merge!(@other_tree)

      assert(!@root['Child1']['Child1a'].nil?, ".merge() has not included ['Child1']['Child1a'] from other_tree.")
      assert(!@root['Child1']['Child1b'].nil?, ".merge() has not included ['Child1']['Child1b'] from other_tree.")
      assert(!@root['Child3']['Child3a'].nil?, ".merge() has not included ['Child3']['Child3a'] from other_tree.")
      assert(!@root['Child2'].nil?, ".merge() has not included ['Child2'] from self.")
      assert(!@root['Child3']['Child3a']['Child3a1'].nil?,
             ".merge() has not included ['Child3']['Child3a']['Child3a1'] from other_tree.")
      assert(!@root['Child3']['Child4'].nil?, ".merge() has not included ['Child3']['Child4'] from self.")

      assert_raise(ArgumentError) { @root.merge!(@other_tree2) }
      assert_raise(TypeError) { @root.merge!('ROOT') }
    end
  end
end
