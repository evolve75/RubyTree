# tree_initialize_spec.rb - This file is part of the RubyTree package.
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
# initialize_spec.rb
#
# Author:  Anupam Sengupta
#
# Copyright (C) 2015-2026 Anupam Sengupta <anupamsg@gmail.com>
#
# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe Tree do
  describe '#initialize with empty name and nil content' do
    let(:tree) { Tree::TreeNode.new('') }

    it 'creates the tree node with name as ""' do
      expect(tree.name).to eq('')
    end

    it "has 'nil' content" do
      expect(tree.content).to be_nil
    end

    it_behaves_like 'detached node'
  end

  describe "#initialize with name 'A' and nil content" do
    let(:tree) { Tree::TreeNode.new('A') }

    it 'creates the tree node with name as "A"' do
      expect(tree.name).to eq('A')
    end

    it "has 'nil' content" do
      expect(tree.content).to be_nil
    end

    it_behaves_like 'detached node'
  end

  describe "#initialize with node name 'A' and some content" do
    let(:sample) { 'some content' }
    let(:tree) { Tree::TreeNode.new('A', sample) }

    it 'creates the tree node with name as "A"' do
      expect(tree.name).to eq('A')
    end

    it 'has some content' do
      expect(tree.content).to eq(sample)
    end

    it_behaves_like 'detached node'
  end
end
