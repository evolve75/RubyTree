# example_aa_tree.rb - This file is part of the RubyTree package.
#
# = example_aa_tree.rb - Basic usage of Tree::AATree.
#
# Provides a short, runnable example of inserting, searching, and deleting
# key/value pairs.
#
# Structure:
#
#     30
#    /  \
#   20  40
#     \
#     25
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
# Load the AA-tree implementation.
require 'tree/aatree'

# Create a tree with the root and its direct children.
tree = Tree::AATree.new([[30, 'thirty'], [20, 'twenty'], [40, 'forty']])
# Insert the right child under 20 to match the structure.
tree.insert(25, 'twenty-five')

# Traverse keys in sorted order.
puts "keys: #{tree.keys.inspect}"

# Search for an existing key.
puts "value for 20: #{tree.search(20)}"

# Update a value using bracket assignment.
tree[30] = 'THIRTY'
# Confirm the updated value.
puts "updated value for 30: #{tree.search(30)}"

# Delete a key from the tree.
removed = tree.delete(25)
# Report the deleted value.
puts "removed: #{removed}"

# Serialize to a hash.
serialized_hash = tree.to_h
# Rebuild from the hash.
rebuilt_from_hash = Tree::AATree.from_hash(serialized_hash)
# Show the rebuilt keys.
puts "from_hash keys: #{rebuilt_from_hash.keys.inspect}"

# Serialize to JSON.
serialized_json = tree.to_json
# Parse JSON back into a tree instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show the JSON-rebuilt keys.
puts "from_json keys: #{rebuilt_from_json.keys.inspect}"
