# aa_tree_spec.rb - This file is part of the RubyTree package.
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
require 'tree/aatree'

RSpec.describe Tree::AATree do
  def build_tree(entries)
    described_class.new(entries)
  end

  describe 'common key/value usage' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b'], [5, 'c']]) }

    it 'supports lookup by key' do
      expect(tree.search(20)).to eq('b')
    end

    it 'keeps keys in sorted order' do
      expect(tree.keys).to eq([5, 10, 20])
    end
  end

  describe 'index-style access' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b']]) }

    it 'reads values with []' do
      expect(tree[20]).to eq('b')
    end

    it 'updates values with []=' do
      tree[20] = 'z'
      expect(tree.search(20)).to eq('z')
    end
  end

  describe 'delete' do
    let(:tree) { build_tree([[10, 'a'], [20, 'b'], [5, 'c']]) }

    it 'returns the deleted value' do
      expect(tree.delete(5)).to eq('c')
    end

    it 'removes the key from lookup results' do
      tree.delete(5)
      expect(tree.search(5)).to be_nil
    end

    it 'keeps ordered keys after deletion' do
      tree.delete(5)
      expect(tree.keys).to eq([10, 20])
    end
  end

  describe 'enumeration and serialization usage' do
    let(:tree) { build_tree([[10, 'a'], [5, 'b'], [20, 'c']]) }

    it 'enumerates entries in key order' do
      pairs = tree.map { |entry| [entry.key, entry.value] }
      expect(pairs).to eq([[5, 'b'], [10, 'a'], [20, 'c']])
    end

    it 'round-trips via hash conversion' do
      rebuilt = described_class.from_hash(tree.to_h)
      expect(rebuilt.to_a).to eq(tree.to_a)
    end
  end

  describe 'shovel insertion' do
    let(:tree) { build_tree([]) }

    it 'returns the inserted entry' do
      expect((tree << [10, 'a']).key).to eq(10)
    end

    it 'stores the inserted value' do
      tree << [10, 'a']
      expect(tree.search(10)).to eq('a')
    end
  end

  describe 'input validation' do
    it 'rejects nil keys' do
      tree = build_tree([])
      expect { tree.insert(nil, 'a') }.to raise_error(ArgumentError)
    end
  end
end
