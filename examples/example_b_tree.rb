# example_b_tree.rb - This file is part of the RubyTree package.
#
# = example_b_tree.rb - Basic usage of Tree::BTree.
#
# Provides a short, runnable example of inserting, searching, and deleting
# key/value pairs in a B-tree.
#
# Structure:
#
#         [10|20|30]
#        /   |   |  \
#    [1|5] [12|18] [22|26] [35|40]
#
# Author:: Anupam Sengupta (https://github.com/evolve75)
#
# Copyright (c) 2026 Anupam Sengupta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
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

require 'tree/btree'

pairs = [[10, 'ten'], [5, 'five'], [20, 'twenty']]
entries = pairs.map { |key, value| { key: key, value: value } }
tree = Tree::BTree.new(2, entries)

tree.insert(15, 'fifteen')
puts "search 20: #{tree.search(20)}"

# Bracket access uses the key.
puts "value for 10: #{tree[10]}"

tree[10] = 'TEN'
puts "updated value for 10: #{tree.search(10)}"

tree.delete(5)
puts "keys: #{tree.keys.inspect}"
