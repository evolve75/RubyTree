# The net is like a vast sea of lutefisk with tiny dinosaur brains embedded
# in it here and there. Any given spoonful will likely have an IQ of 1, but
# occasional spoonfuls may have an IQ more than six times that!
#	-- James 'Kibo' Parry
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
