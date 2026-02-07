# fixtures_shared.rb - This file is part of the RubyTree package.
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

module TreeTestFixtures
  def build_basic_tree_nodes
    root = Tree::TreeNode.new('ROOT', 'Root Node')
    child1 = Tree::TreeNode.new('Child1', 'Child Node 1')
    child2 = Tree::TreeNode.new('Child2', 'Child Node 2')
    child3 = Tree::TreeNode.new('Child3', 'Child Node 3')
    child4 = Tree::TreeNode.new('Child4', 'Grand Child 1')
    child5 = Tree::TreeNode.new('Child5', 'Child Node 4')

    {
      root: root,
      child1: child1,
      child2: child2,
      child3: child3,
      child4: child4,
      child5: child5
    }
  end

  def attach_basic_tree(nodes)
    nodes[:root] << nodes[:child1]
    nodes[:root] << nodes[:child2]
    nodes[:root] << nodes[:child3] << nodes[:child4]
    nodes
  end

  def build_basic_tree
    attach_basic_tree(build_basic_tree_nodes)
  end

  def build_binary_tree_nodes
    root = Tree::BinaryTreeNode.new('ROOT', 'Root Node')
    left_child1 = Tree::BinaryTreeNode.new('A Child at Left', 'Child Node @ left')
    right_child1 = Tree::BinaryTreeNode.new('B Child at Right', 'Child Node @ right')

    {
      root: root,
      left_child1: left_child1,
      right_child1: right_child1
    }
  end
end
