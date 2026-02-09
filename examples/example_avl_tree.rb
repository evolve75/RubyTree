# example_avl_tree.rb - This file is part of the RubyTree package.
#
# = example_avl_tree.rb - Basic usage of Tree::AvlTreeNode.
#
# Provides a short, runnable example of inserting, searching, and deleting
# keys while maintaining balance.
#
# Structure:
#
#       4
#      / \
#     2   6
#    / \ / \
#   1  3 5  7
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

# Load JSON for parsing serialized trees.
require 'json'
# Load the AVL-tree implementation.
require 'tree/avltree'

# Create the root node.
root = Tree::AvlTreeNode.new('root', 4)
# Insert the left subtree values.
root.insert('n2', 2)
# Insert the right subtree values.
root.insert('n6', 6)
# Insert the left-left value.
root.insert('n1', 1)
# Insert the left-right value.
root.insert('n3', 3)
# Insert the right-left value.
root.insert('n5', 5)
# Insert the right-right value.
root.insert('n7', 7)

# Traverse in-order to show sorted keys.
puts "in-order: #{root.inordered_each.map(&:content).inspect}"

# Search for a key.
puts "search 6: #{root.search(6).content}"

# Delete a key.
root.delete(2)
# Show the updated traversal after deletion.
puts "after delete 2: #{root.inordered_each.map(&:content).inspect}"

# Serialize to a hash.
serialized_hash = root.to_h
# Rebuild from the hash.
rebuilt_from_hash = Tree::AvlTreeNode.from_hash(serialized_hash)
# Show rebuilt traversal.
puts "from_hash in-order: #{rebuilt_from_hash.inordered_each.map(&:content).inspect}"

# Serialize to JSON.
serialized_json = root.to_json
# Parse JSON back into a tree instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show JSON-rebuilt traversal.
puts "from_json in-order: #{rebuilt_from_json.inordered_each.map(&:content).inspect}"
