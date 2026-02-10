# splay_tree_node_spec.rb - This file is part of the RubyTree package.
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

require 'rspec'
require 'spec_helper'
require 'tree/splaytree'

RSpec.describe Tree::SplayTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def bst_valid?(node, min, max)
    return true unless node
    return false if min && node.content < min
    return false if max && node.content > max

    bst_valid?(node.left_child, min, node.content) && bst_valid?(node.right_child, node.content, max)
  end

  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8]) }

  it 'keeps in-order traversal sorted after inserts' do
    expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
  end

  it 'maintains BST invariants after inserts' do
    expect(bst_valid?(root.root, nil, nil)).to be(true)
  end

  it 'finds existing keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'splays found keys to the root' do
    root.search(12)
    expect(root.root.content).to eq(12)
  end

  it 'supports delete in common mutation flows' do
    root.delete(15)
    expect(inorder_contents(root.root)).to eq(inorder_contents(root.root).sort)
  end
end
