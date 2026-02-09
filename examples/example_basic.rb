# example_basic.rb - This file is part of the RubyTree package.
#
# = example_basic.rb - Basic usage of Tree::TreeNode.
#
# The following example implements this tree structure:
#
#                    +------------+
#                    |    ROOT    |
#                    +-----+------+
#            +-------------+------------+
#            |                          |
#    +-------+-------+          +-------+-------+
#    |  CHILD 1      |          |  CHILD 2      |
#    +-------+-------+          +---------------+
#            |
#            |
#    +-------+-------+
#    | GRANDCHILD 1  |
#    +---------------+
#
#
# Author:: Anupam Sengupta (https://github.com/evolve75)
#
# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
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
# Load the core tree library.
require 'tree'

# Create the root node with a name and content.
root_node = Tree::TreeNode.new('ROOT', 'Root Content')
# Print the tree containing only the root.
root_node.print_tree

# Create the first child node.
child1_node = Tree::TreeNode.new('CHILD 1', 'Child1 Content')
# Create the grandchild node.
grandchild1_node = Tree::TreeNode.new('GRANDCHILD 1', 'GrandChild1 Content')
# Add CHILD 1 under ROOT.
root_node << child1_node
# Add GRANDCHILD 1 under CHILD 1.
child1_node << grandchild1_node
# Add CHILD 2 under ROOT.
root_node << Tree::TreeNode.new('CHILD 2', 'Child2 Content')

# Print the updated tree.
root_node.print_tree

# Access CHILD 1 by name.
child1 = root_node['CHILD 1']
# Access GRANDCHILD 1 by name.
grand_child1 = root_node['CHILD 1']['GRANDCHILD 1']

# Collect siblings of CHILD 1.
siblings_of_child1 = child1.siblings
# Display sibling names.
puts "siblings: #{siblings_of_child1.map(&:name).inspect}"

# Collect immediate children of ROOT.
children_of_root = root_node.children
# Display child names.
puts "children: #{children_of_root.map(&:name).inspect}"

# Retrieve the parent of CHILD 1.
parent = child1.parent
# Display the parent name.
puts "parent: #{parent.name}"

# Collect a pre-order traversal of node names.
names = root_node.map(&:name)
# Display traversal results.
puts "preorder: #{names.inspect}"

# Serialize the tree to a hash.
tree_hash = root_node.to_h
# Rebuild a tree from the hash.
from_hash = Tree::TreeNode.from_hash(tree_hash)
# Display the rebuilt root name.
puts "from_hash root: #{from_hash.name}"

# Serialize the tree to JSON.
tree_json = root_node.to_json
# Parse JSON back into a tree instance.
from_json = JSON.parse(tree_json, create_additions: true)
# Display the JSON rebuilt root name.
puts "from_json root: #{from_json.name}"

# Remove CHILD 1 from ROOT.
root_node.remove!(child1)
# Print the tree after removal.
root_node.print_tree
