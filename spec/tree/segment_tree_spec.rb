# segment_tree_spec.rb - This file is part of the RubyTree package.
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
require 'tree/segmenttree'

RSpec.describe Tree::SegmentTree do
  def build_tree(values)
    described_class.new(values.length, values)
  end

  let(:tree) { build_tree([1, 2, 3, 4, 5]) }

  it 'supports range-sum queries for common usage' do
    expect(tree.range_sum(1, 3)).to eq(9)
  end

  it 'supports point updates via []=' do
    tree[1] = 5
    expect(tree[1]).to eq(5)
  end

  it 'supports enumeration in index order' do
    expect(tree.each.to_a).to eq([1, 2, 3, 4, 5])
  end

  it 'supports hash round-trips' do
    copy = described_class.from_hash(tree.to_h)
    expect(copy.to_a).to eq(tree.to_a)
  end

  it 'rejects invalid tree size' do
    expect { described_class.new(0) }.to raise_error(ArgumentError)
  end

  it 'does not support shovel insertion' do
    expect(tree.respond_to?(:<<)).to be(false)
  end
end
