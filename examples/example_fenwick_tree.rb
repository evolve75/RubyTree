# example_fenwick_tree.rb - This file is part of the RubyTree package.
#
# = example_fenwick_tree.rb - Basic usage of Tree::FenwickTree.
#
# Provides a short, runnable example of prefix and range sums.
#
# Structure:
#
# Index: 1 2 3 4 5 6 7 8
# Tree:  t1 t2 t3 t4 t5 t6 t7 t8
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
# Load the Fenwick tree implementation.
require 'tree/fenwicktree'

# Seed values for indices 0..7.
values = [1, 2, 3, 4, 5, 6, 7, 8]
# Create a Fenwick tree from the values.
tree = Tree::FenwickTree.new(values.length, values)

# Query a prefix sum.
puts "sum(3): #{tree.sum(3)}"

# Query a range sum.
puts "range_sum(1, 3): #{tree.range_sum(1, 3)}"

# Apply a delta update to index 2.
tree.update(2, 5)
# Query the prefix sum after the update.
puts "after update sum(3): #{tree.sum(3)}"

# Read the value at index 4.
puts "tree[4]: #{tree[4]}"

# Iterate over all values.
puts "values: #{tree.each.to_a.inspect}"

# Serialize to a hash.
serialized_hash = tree.to_h
# Rebuild from the hash.
rebuilt_from_hash = Tree::FenwickTree.from_hash(serialized_hash)
# Show rebuilt values.
puts "from_hash values: #{rebuilt_from_hash.to_a.inspect}"

# Serialize to JSON.
serialized_json = tree.to_json
# Parse JSON back into a tree instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show JSON-rebuilt values.
puts "from_json values: #{rebuilt_from_json.to_a.inspect}"
