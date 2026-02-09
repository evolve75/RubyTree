# example_binary_max_heap.rb - This file is part of the RubyTree package.
#
# = example_binary_max_heap.rb - Basic usage of Tree::BinaryMaxHeapNode.
#
# Provides a short, runnable example of a max-priority queue.
#
# Structure:
#
#        9
#      /   \
#     7     6
#    / \   /
#   3  2  1
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

# Load JSON for parsing serialized heaps.
require 'json'
# Load the binary max-heap implementation.
require 'tree/binarymaxheap'

# Create the heap root.
heap = Tree::BinaryMaxHeapNode.new('root', 9)
# Insert values to match the heap structure.
heap.insert('n7', 7)
# Insert another value.
heap.insert('n6', 6)
# Insert another value.
heap.insert('n3', 3)
# Insert another value.
heap.insert('n2', 2)
# Insert the last value.
heap.insert('n1', 1)

# Peek at the maximum value.
puts "peek: #{heap.peek}"

# Traverse by breadth to show heap shape.
breadth_values = heap.breadth_each.map(&:content)
# Display the breadth traversal.
puts "breadth: #{breadth_values.inspect}"

# Extract values in heap order.
extracted = []
# Loop until the heap is empty.
loop do
  # Extract the current maximum.
  value = heap.extract
  # Stop when extraction returns nil.
  break unless value

  # Collect the extracted value.
  extracted << value
  # Close the extraction loop.
end
# Display extracted values.
puts "extracted: #{extracted.inspect}"

# Serialize to JSON.
serialized_json = heap.to_json
# Parse JSON back into a heap instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show the rebuilt heap root value.
puts "from_json root: #{rebuilt_from_json.content}"
