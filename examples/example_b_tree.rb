# example_b_tree.rb - This file is part of the RubyTree package.
#
# = example_b_tree.rb - Basic usage of Tree::BTree.
#
# Provides a short, runnable example of inserting, searching, and deleting
# key/value pairs in a B-tree.
#
# Structure (from the from_hash example below):
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

# Load JSON for parsing serialized trees.
require 'json'
# Load the B-tree implementation.
require 'tree/btree'

# Create an empty B-tree with minimum degree 2.
tree = Tree::BTree.new(2)

# Insert the root entries.
tree.insert(10, 'ten')
# Insert the next root entry.
tree.insert(20, 'twenty')
# Insert the next root entry.
tree.insert(30, 'thirty')
# Insert values that will populate the left child.
tree.insert(1, 'one')
# Insert values that will populate the left child.
tree.insert(5, 'five')
# Insert values that will populate the second child.
tree.insert(12, 'twelve')
# Insert values that will populate the second child.
tree.insert(18, 'eighteen')
# Insert values that will populate the third child.
tree.insert(22, 'twenty-two')
# Insert values that will populate the third child.
tree.insert(26, 'twenty-six')
# Insert values that will populate the fourth child.
tree.insert(35, 'thirty-five')
# Insert values that will populate the fourth child.
tree.insert(40, 'forty')

# Traverse keys in order.
puts "keys: #{tree.keys.inspect}"

# Search for an existing key.
puts "search 22: #{tree.search(22)}"

# Insert a new key/value pair.
tree.insert(28, 'twenty-eight')
# Show keys after insertion.
puts "after insert keys: #{tree.keys.inspect}"

# Delete a key/value pair.
removed = tree.delete(1)
# Show the removed value.
puts "removed: #{removed}"

# Serialize to a hash.
serialized_hash = tree.to_h
# Rebuild from the hash.
rebuilt_from_hash = Tree::BTree.from_hash(serialized_hash)
# Show rebuilt keys.
puts "from_hash keys: #{rebuilt_from_hash.keys.inspect}"

# Serialize to JSON.
serialized_json = tree.to_json
# Parse JSON into a hash for inspection.
parsed_json = JSON.parse(serialized_json)
# Show parsed JSON keys.
puts "json keys: #{parsed_json.keys.inspect}"

# Start the hash representation of the diagrammed tree.
tree_hash = {
  # Specify the minimum degree.
  min_degree: 2,
  # Define the root node.
  root: {
    # Provide the root entries.
    entries: [
      # First root entry.
      { key: 10, value: 'ten' },
      # Second root entry.
      { key: 20, value: 'twenty' },
      # Third root entry.
      { key: 30, value: 'thirty' }
      # Close the root entries list.
    ],
    # Mark the root as an internal node.
    leaf: false,
    # Define the root children.
    children: [
      # Define the first child.
      {
        # Provide entries for the first child.
        entries: [
          # First entry in the first child.
          { key: 1, value: 'one' },
          # Second entry in the first child.
          { key: 5, value: 'five' }
          # Close the first child entries list.
        ],
        # Mark the child as a leaf.
        leaf: true,
        # Leaf nodes have no children.
        children: []
        # Close the first child hash.
      },
      # Define the second child.
      {
        # Provide entries for the second child.
        entries: [
          # First entry in the second child.
          { key: 12, value: 'twelve' },
          # Second entry in the second child.
          { key: 18, value: 'eighteen' }
          # Close the second child entries list.
        ],
        # Mark the child as a leaf.
        leaf: true,
        # Leaf nodes have no children.
        children: []
        # Close the second child hash.
      },
      # Define the third child.
      {
        # Provide entries for the third child.
        entries: [
          # First entry in the third child.
          { key: 22, value: 'twenty-two' },
          # Second entry in the third child.
          { key: 26, value: 'twenty-six' }
          # Close the third child entries list.
        ],
        # Mark the child as a leaf.
        leaf: true,
        # Leaf nodes have no children.
        children: []
        # Close the third child hash.
      },
      # Define the fourth child.
      {
        # Provide entries for the fourth child.
        entries: [
          # First entry in the fourth child.
          { key: 35, value: 'thirty-five' },
          # Second entry in the fourth child.
          { key: 40, value: 'forty' }
          # Close the fourth child entries list.
        ],
        # Mark the child as a leaf.
        leaf: true,
        # Leaf nodes have no children.
        children: []
        # Close the fourth child hash.
      }
      # Close the children list.
    ]
    # Close the root hash.
  }
  # Close the tree hash.
}

# Rebuild the diagrammed tree from the hash representation.
from_hash_tree = Tree::BTree.from_hash(tree_hash)
# Show keys for the diagrammed tree.
puts "diagram keys: #{from_hash_tree.keys.inspect}"
