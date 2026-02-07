# benchmark_tree.rb - This file is part of the RubyTree package.
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

require 'benchmark'
require 'tree'

def build_tree(depth:, breadth:)
  root = Tree::TreeNode.new('root')
  level = [root]

  depth.times do |d|
    next_level = []
    level.each_with_index do |node, idx|
      breadth.times do |b|
        child = Tree::TreeNode.new("n#{d}-#{idx}-#{b}")
        node << child
        next_level << child
      end
    end
    level = next_level
  end

  root
end

if $PROGRAM_NAME == __FILE__
  depth = (ENV['TREE_BENCH_DEPTH'] || 5).to_i
  breadth = (ENV['TREE_BENCH_BREADTH'] || 4).to_i

  tree = build_tree(depth: depth, breadth: breadth)

  Benchmark.bm(28) do |x|
    x.report('root lookups') do
      50_000.times { tree.children.first.root }
    end

    x.report('preorder traversal') do
      tree.each { |_node| nil }
    end

    x.report('postorder traversal') do
      tree.postordered_each { |_node| nil }
    end

    x.report('breadth traversal') do
      tree.breadth_each { |_node| nil }
    end

    x.report('size') do
      1000.times { tree.size }
    end

    x.report('to_s') do
      1000.times { tree.to_s }
    end
  end
end
