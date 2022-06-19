#!/usr/bin/env ruby
#
# tree_spec.rb
#
# Author:  Anupam Sengupta
# Time-stamp: <2022-06-19 16:47:33 anupam>
# Copyright (C) 2015-2022 Anupam Sengupta <anupamsg@gmail.com>
#

require 'rspec'
require 'spec_helper'

describe Tree do
  class SpecializedTreeNode < Tree::TreeNode; end

  shared_examples_for 'any detached node' do
    it 'should not equal "Object.new"' do
      expect(@tree).not_to eq(Object.new)
    end
    it 'should not equal 1 or any other fixnum' do
      expect(@tree).not_to eq(1)
    end
    it 'identifies itself as a root node' do
      expect(@tree.is_root?).to eq(true)
    end
    it 'does not have a parent node' do
      expect(@tree.parent).to eq(nil)
    end
  end
  context '#initialize', 'with empty name and nil content' do
    before(:each) do
      @tree = Tree::TreeNode.new('')
    end
    it 'creates the tree node with name as ""' do
      expect(@tree.name).to eq('')
    end
    it "has 'nil' content" do
      expect(@tree.content).to eq(nil)
    end

    it_behaves_like 'any detached node'
  end

  context '#initialize', "with name 'A' and nil content" do
    before(:each) do
      @tree = Tree::TreeNode.new('A')
    end

    it 'creates the tree node with name as "A"' do
      expect(@tree.name).to eq('A')
    end
    it "has 'nil' content" do
      expect(@tree.content).to eq(nil)
    end

    it_behaves_like 'any detached node'
  end

  context '#initialize', "with node name 'A' and some content" do
    before(:each) do
      @sample = 'sample'
      @tree = Tree::TreeNode.new('A', @sample)
    end

    it 'creates the tree node with name as "A"' do
      expect(@tree.name).to eq('A')
    end
    it "has some content #{@sample}" do
      expect(@tree.content).to eq(@sample)
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
      expect(node1 <=> nil).to be(nil)
    end

    it 'does not allow comparison with other objects' do
      expect(node1 <=> 'c').to be(nil)
    end
  end

  describe 'serialization' do
    let(:node1) { SpecializedTreeNode.new('a') }
    let(:serialized_node1) { Marshal.dump(node1) }
    let(:node2) { Tree::TreeNode.new('b') }
    let(:serialized_node2) { Marshal.dump(node2) }
    let(:tree) do
      SpecializedTreeNode.new('root').tap do |root|
        root << node1
        root << node2
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
end
