# binary_max_heap_node_spec.rb - This file is part of the RubyTree package.
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
require 'tree/binarymaxheap'

RSpec.describe Tree::BinaryMaxHeapNode do
  def build_heap(values)
    root = described_class.new('root', values.first)
    values.drop(1).each_with_index do |value, index|
      root.insert("n#{index}", value)
    end
    root
  end

  def extract_all(node)
    values = []
    while (value = node.extract)
      values << value
    end
    values
  end

  describe 'priority queue usage' do
    let(:heap) { build_heap([10, 5, 15, 2, 7]) }

    it 'peeks the maximum value' do
      expect(heap.peek).to eq(15)
    end

    it 'keeps the maximum after peek' do
      heap.peek
      expect(heap.peek).to eq(15)
    end
  end

  describe 'sorted extraction usage' do
    it 'extracts values in descending order' do
      values = [10, 5, 15, 2, 7, 12]
      heap = build_heap(values)
      expect(extract_all(heap)).to eq(values.sort.reverse)
    end
  end

  describe 'search and delete usage' do
    let(:heap) { build_heap([10, 5, 15, 2, 7, 12]) }

    it 'finds an inserted key' do
      expect(heap.search(7).content).to eq(7)
    end

    it 'returns the deleted node' do
      expect(heap.delete(7).content).to eq(7)
    end

    it 'removes deleted keys from search' do
      heap.delete(7)
      expect(heap.search(7)).to be_nil
    end

    it 'returns nil for missing keys' do
      expect(heap.search(99)).to be_nil
    end
  end
end
