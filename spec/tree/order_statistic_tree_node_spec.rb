# order_statistic_tree_node_spec.rb - This file is part of the RubyTree package.
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
require 'tree/orderstatistictree'

RSpec.describe Tree::OrderStatisticTreeNode do
  def build_tree(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  def subtree_size_valid?(node)
    return true unless node&.content

    return false unless subtree_size_matches?(node)

    subtree_size_valid?(node.left_child) && subtree_size_valid?(node.right_child)
  end

  def subtree_size_matches?(node)
    left_size = node.left_child&.subtree_size || 0
    right_size = node.right_child&.subtree_size || 0
    node.subtree_size == left_size + right_size + 1
  end

  let(:root) { build_tree([10, 5, 15, 12, 18, 2, 8, 6, 1]) }

  it 'supports rank queries for common usage' do
    expect(root.rank(10)).to eq(5)
  end

  it 'supports select queries for common usage' do
    expect(root.select(4).content).to eq(8)
  end

  it 'returns nil for missing ranks' do
    expect(root.rank(7)).to be_nil
  end

  it 'maintains subtree-size metadata after inserts' do
    expect(subtree_size_valid?(root)).to be(true)
  end

  it 'maintains subtree-size metadata after delete' do
    root.delete(12)
    expect(subtree_size_valid?(root)).to be(true)
  end
end
