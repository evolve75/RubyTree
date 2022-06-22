#!/usr/bin/env ruby
#
# tree_spec.rb
#
# Author:  Anupam Sengupta
# Time-stamp: <2022-06-22 13:52:50 anupam>
# Copyright (C) 2015-2022 Anupam Sengupta <anupamsg@gmail.com>
#
# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

class SpecializedTreeNode < Tree::TreeNode; end

describe Tree do
  shared_examples_for 'any detached node' do
    it 'does not equal "Object.new"' do
      expect(tree).not_to eq(Object.new)
    end

    it 'does not equal 1 or any other fixnum' do
      expect(tree).not_to eq(1)
    end

    it 'identifies itself as a root node' do
      expect(tree.root?).to be(true)
    end

    it 'does not have a parent node' do
      expect(tree.parent).to be_nil
    end
  end

  describe '#initialize with empty name and nil content' do
    let(:tree) { Tree::TreeNode.new('') }

    it 'creates the tree node with name as ""' do
      expect(tree.name).to eq('')
    end

    it "has 'nil' content" do
      expect(tree.content).to be_nil
    end

    it_behaves_like 'any detached node'
  end

  describe "#initialize with name 'A' and nil content" do
    let(:tree) { Tree::TreeNode.new('A') }

    it 'creates the tree node with name as "A"' do
      expect(tree.name).to eq('A')
    end

    it "has 'nil' content" do
      expect(tree.content).to be_nil
    end

    it_behaves_like 'any detached node'
  end

  describe "#initialize with node name 'A' and some content" do
    sample = 'some content'
    let(:tree) { Tree::TreeNode.new('A', sample) }

    it 'creates the tree node with name as "A"' do
      expect(tree.name).to eq('A')
    end

    it "has some content #{sample}" do
      expect(tree.content).to eq(sample)
    end

    it_behaves_like 'any detached node'
  end

  describe 'comparison' do
    let(:node1) { Tree::TreeNode.new('a') }
    let(:node2) { SpecializedTreeNode.new('b') }

    it 'allows comparison of specialized tree nodes' do
      expect(node1 <=> node2).to be_eql(-1)
    end

    it 'does not allow comparison with nil' do
      expect(node1 <=> nil).to be_nil
    end

    it 'does not allow comparison with other objects' do
      expect(node1 <=> 'c').to be_nil
    end
  end

  describe 'serialization' do
    let(:serialized_node1) { Marshal.dump(SpecializedTreeNode.new('a')) }
    let(:serialized_node2) { Marshal.dump(Tree::TreeNode.new('b')) }
    let(:tree) do
      SpecializedTreeNode.new('root').tap do |root|
        root << SpecializedTreeNode.new('a')
        root << Tree::TreeNode.new('b')
      end
    end
    let(:serialized_tree) { Marshal.dump(tree) }

    it 'parses the serialized specialized tree node correctly (root)' do
      expect(Marshal.load(serialized_tree)).to be_a(SpecializedTreeNode)
    end

    it 'parses the serialized specialized tree node correctly (child)' do
      expect(Marshal.load(serialized_tree).children.first).to \
        be_a(SpecializedTreeNode)
    end

    it 'parses the serialized tree node correctly' do
      expect(Marshal.load(serialized_node2)).to be_a(Tree::TreeNode)
    end
  end

  shared_examples_for 'any cloned node' do
    it 'is equal to the original' do
      expect(clone).to eq tree
    end

    it 'is not identical to the original' do
      expect(clone).not_to be tree
    end
  end

  describe '#detached_copy', 'Without content' do
    let(:tree) { Tree::TreeNode.new('A', nil) }
    let(:clone) { tree.detached_copy }

    it_behaves_like 'any cloned node'
  end

  describe '#detached_copy with clonable content' do
    let(:tree) { Tree::TreeNode.new('A', 'clonable content') }
    let(:clone) { tree.detached_copy }

    it 'makes a clone of the content' do
      expect(clone.content).to eq tree.content
    end

    it 'is not the same as the original content' do
      expect(clone.content).not_to be tree.content
    end

    it_behaves_like 'any cloned node'
  end

  describe '#detached_copy with unclonable content' do
    let(:tree) { Tree::TreeNode.new('A', :unclonable_content) }
    let(:clone) { tree.detached_copy }

    it 'retains the original content' do
      expect(clone.content).to be tree.content
    end

    it_behaves_like 'any cloned node'
  end

  describe '#detached_copy with false as content' do
    let(:tree) { Tree::TreeNode.new('A', false) }
    let(:clone) { tree.detached_copy }

    it 'retains the original content' do
      expect(clone.content).to be tree.content
    end

    it_behaves_like 'any cloned node'
  end
end
