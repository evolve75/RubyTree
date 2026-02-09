# example_treap.rb - This file is part of the RubyTree package.
#
# = example_treap.rb - Basic usage of Tree::TreapNode.
#
# Provides a short, runnable example of ordered insert/search/delete with
# randomized priorities.
#
# Structure:
#
#    key:5,p:10
#     /       \
# key:2,p:20  key:8,p:30
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
# Load the treap implementation.
require 'tree/treap'

# Create the root node with an explicit priority.
root = Tree::TreapNode.new('root', 5, priority: 10)
# Insert the left child with a higher priority value.
root.insert('n2', 2, priority: 20)
# Insert the right child with a higher priority value.
root.insert('n8', 8, priority: 30)

# Traverse in-order to show sorted keys.
puts "in-order: #{root.inordered_each.map(&:content).inspect}"

# Search for a key.
puts "search 8: #{root.search(8).content}"

# Delete a key.
root.delete(2)
# Show traversal after deletion.
puts "after delete 2: #{root.inordered_each.map(&:content).inspect}"

# Serialize to JSON.
serialized_json = root.to_json
# Parse JSON back into a tree instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show JSON-rebuilt traversal.
puts "from_json in-order: #{rebuilt_from_json.inordered_each.map(&:content).inspect}"
