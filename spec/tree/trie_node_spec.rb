# trie_node_spec.rb - This file is part of the RubyTree package.
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
require 'tree/trie'

RSpec.describe Tree::TrieNode do
  def build_trie(words)
    root = described_class.new('')
    words.each { |word| root.insert(word) }
    root
  end

  let(:root) { build_trie(%w[cat car cart dog]) }

  it 'supports word membership checks' do
    expect(root.include?('cat')).to be(true)
  end

  it 'returns false for missing words' do
    expect(root.include?('cap')).to be(false)
  end

  it 'supports prefix checks' do
    expect(root.prefix?('ca')).to be(true)
  end

  it 'supports prefix-based word listing' do
    expect(root.words_with_prefix('ca').sort).to eq(%w[car cart cat])
  end

  it 'supports delete for common mutation flows' do
    root.delete('cart')
    expect(root.include?('cart')).to be(false)
  end

  it 'keeps unrelated words after delete' do
    root.delete('cart')
    expect(root.include?('car')).to be(true)
  end

  it 'supports shovel insertion shorthand' do
    trie = described_class.new('')
    trie << 'cat'
    expect(trie.include?('cat')).to be(true)
  end
end
