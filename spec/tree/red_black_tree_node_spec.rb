# red_black_tree_node_spec.rb - This file is part of the RubyTree package.
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
require 'tree/redblacktree'

RSpec.describe Tree::RedBlackTreeNode do
  def inorder_contents(node)
    result = []
    node.inordered_each { |entry| result << entry.content }
    result
  end

  def red_black_valid?(node)
    root = node.root
    return true unless root.content
    return false unless root.black?

    red_children_valid?(root) && black_height_valid?(root)
  end

  def red_children_valid?(node)
    return true unless node
    return false if node.red? && (node.left_child&.red? || node.right_child&.red?)

    red_children_valid?(node.left_child) && red_children_valid?(node.right_child)
  end

  def black_height_valid?(node)
    target = nil
    check = lambda do |current, count|
      if current.nil?
        target ||= count
        return count == target
      end

      count += 1 if current.black?
      check.call(current.left_child, count) && check.call(current.right_child, count)
    end

    check.call(node, 0)
  end

  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8]) }

  it 'finds inserted keys' do
    expect(root.search(15).content).to eq(15)
  end

  it 'returns nil for missing keys' do
    expect(root.search(7)).to be_nil
  end

  it 'keeps in-order traversal sorted' do
    expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
  end

  it 'maintains red-black invariants after inserts' do
    expect(red_black_valid?(root)).to be(true)
  end

  describe 'delete usage' do
    before { root.delete(12) }

    it 'removes deleted keys from search' do
      expect(root.search(12)).to be_nil
    end

    it 'keeps in-order traversal sorted after delete' do
      expect(inorder_contents(root)).to eq(inorder_contents(root).sort)
    end

    it 'maintains red-black invariants after delete' do
      expect(red_black_valid?(root)).to be(true)
    end
  end
end
