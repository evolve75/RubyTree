# The net is like a vast sea of lutefisk with tiny dinosaur brains embedded
# in it here and there. Any given spoonful will likely have an IQ of 1, but
# occasional spoonfuls may have an IQ more than six times that!
#	-- James 'Kibo' Parry
#
# detached_copy_spec.rb
#
# Author:  Anupam Sengupta
#
# Copyright (C) 2015-2026 Anupam Sengupta <anupamsg@gmail.com>
#
# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe Tree do
  describe '#detached_copy', 'Without content' do
    let(:tree) { Tree::TreeNode.new('A', nil) }
    let(:clone) { tree.detached_copy }

    it_behaves_like 'cloned node'
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

    it_behaves_like 'cloned node'
  end

  describe '#detached_copy with unclonable content' do
    let(:tree) { Tree::TreeNode.new('A', :unclonable_content) }
    let(:clone) { tree.detached_copy }

    it 'retains the original content' do
      expect(clone.content).to be tree.content
    end

    it_behaves_like 'cloned node'
  end

  describe '#detached_copy with false as content' do
    let(:tree) { Tree::TreeNode.new('A', false) }
    let(:clone) { tree.detached_copy }

    it 'retains the original content' do
      expect(clone.content).to be tree.content
    end

    it_behaves_like 'cloned node'
  end
end
