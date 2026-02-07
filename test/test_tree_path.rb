# test_tree_path.rb - This file is part of the RubyTree package.
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

require 'test/unit'
require_relative '../lib/tree/tree_deps'

module TestTree
  class TestTreePath < Test::Unit::TestCase
    def test_path_as_string
      j = Tree::TreeNode.new('j')
      f = Tree::TreeNode.new('f')
      k = Tree::TreeNode.new('k')
      a = Tree::TreeNode.new('a')
      d = Tree::TreeNode.new('d')
      h = Tree::TreeNode.new('h')
      z = Tree::TreeNode.new('z')
      p = Tree::TreeNode.new('p')
      t = Tree::TreeNode.new('t')
      e = Tree::TreeNode.new('e')

      j << f << a << d << e
      f << h
      h << p
      h << t
      j << k << z

      assert_equal(t.path_as_string, 'j=>f=>h=>t')

      assert_equal(t.path_as_string(' => '), 'j => f => h => t')
      assert_equal(z.path_as_string(' => '), 'j => k => z')
      assert_equal(a.path_as_string(' => '), 'j => f => a')
    end

    def test_path_as_array
      j = Tree::TreeNode.new('j')
      f = Tree::TreeNode.new('f')
      k = Tree::TreeNode.new('k')
      a = Tree::TreeNode.new('a')
      d = Tree::TreeNode.new('d')
      h = Tree::TreeNode.new('h')
      z = Tree::TreeNode.new('z')
      p = Tree::TreeNode.new('p')
      t = Tree::TreeNode.new('t')
      e = Tree::TreeNode.new('e')

      j << f << a << d << e
      f << h
      h << p
      h << t
      j << k << z

      assert_equal(e.path_as_array, %w[j f a d e])
      assert_equal(p.path_as_array, %w[j f h p])
      assert_equal(k.path_as_array, %w[j k])
    end
  end
end
