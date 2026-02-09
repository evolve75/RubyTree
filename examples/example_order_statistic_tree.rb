# example_order_statistic_tree.rb - This file is part of the RubyTree package.
#
# = example_order_statistic_tree.rb - Basic usage of Tree::OrderStatisticTreeNode.
#
# Provides a short, runnable example of rank and select queries.
#
# Structure:
#
#      8(size=7)
#     /        \
#   4(size=3)  12(size=3)
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
# Load the order-statistic tree implementation.
require 'tree/orderstatistictree'

# Create the root node.
root = Tree::OrderStatisticTreeNode.new('root', 8)
# Insert left subtree values.
root.insert('n4', 4)
# Insert right subtree values.
root.insert('n12', 12)
# Insert remaining values.
root.insert('n2', 2)
# Insert remaining values.
root.insert('n6', 6)
# Insert remaining values.
root.insert('n10', 10)
# Insert remaining values.
root.insert('n14', 14)

# Traverse in-order to show sorted keys.
puts "in-order: #{root.inordered_each.map(&:content).inspect}"

# Query the rank of a key.
puts "rank(10): #{root.rank(10)}"

# Select the smallest key.
puts "select(0): #{root.select(0).content}"

# Select the third key.
puts "select(2): #{root.select(2).content}"

# Delete a key and rebalance.
root.delete(2)
# Show traversal after deletion.
puts "after delete 2: #{root.inordered_each.map(&:content).inspect}"

# Serialize to JSON.
serialized_json = root.to_json
# Parse JSON back into a tree instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show JSON-rebuilt traversal.
puts "from_json in-order: #{rebuilt_from_json.inordered_each.map(&:content).inspect}"
