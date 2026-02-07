# test_tree_checks.rb - This file is part of the RubyTree package.
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
  class TestTreeChecks < Test::Unit::TestCase
    def test_checks_disabled_skips_validation
      root = Tree::TreeNode.new('root', nil, { checks: false })
      child1 = Tree::TreeNode.new('dup', nil, { checks: false })
      child2 = Tree::TreeNode.new('dup', nil, { checks: false })

      root.add(child1)
      assert_nothing_raised { root.add(child2) }
      assert_equal(2, root.children.size)
      assert_nil(root[nil])
    end

    def test_checks_enabled_validation_guards
      root = Tree::TreeNode.new('root')
      child1 = Tree::TreeNode.new('dup')
      child2 = Tree::TreeNode.new('dup')

      root.add(child1)
      assert_raise(RuntimeError) { root.add(child2) }
      assert_raise(ArgumentError) { root[nil] }
    end

    def test_checks_disabled_allows_out_of_range_insert
      root = Tree::TreeNode.new('root', nil, { checks: false })
      child1 = Tree::TreeNode.new('child1', nil, { checks: false })
      child2 = Tree::TreeNode.new('child2', nil, { checks: false })

      root.add(child1, 999)
      root.add(child2, -999)
      assert_equal(2, root.children.size)
    end

    def test_checks_setting_propagates_to_children
      root = Tree::TreeNode.new('root', nil, { checks: false })
      child = Tree::TreeNode.new('child')

      root.add(child)
      assert_equal(false, child.checks_enabled?)

      dup = Tree::TreeNode.new('child')
      assert_nothing_raised { root.add(dup) }
    end
  end
end
