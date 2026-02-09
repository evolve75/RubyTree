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

# ..... Example starts.
require 'tree' # Load the library

# ..... Create the root node first. Note that every node has a name and an
# ..... optional content payload.
root_node = Tree::TreeNode.new('ROOT', 'Root Content')
root_node.print_tree

# ..... Now insert the child nodes. Note that you can "chain" the child
# ..... insertions for a given path to any depth.
root_node << Tree::TreeNode.new('CHILD1', 'Child1 Content') \
          << Tree::TreeNode.new('GRANDCHILD1', 'GrandChild1 Content')
root_node << Tree::TreeNode.new('CHILD2', 'Child2 Content')

# ..... Lets print the representation to stdout. This is primarily used for
# ..... debugging purposes.
root_node.print_tree

# ..... Lets directly access children and grandchildren of the root. The can be
# ..... "chained" for a given path to any depth.
child1       = root_node['CHILD1']
grand_child1 = root_node['CHILD1']['GRANDCHILD1']

# ..... Now lets retrieve siblings of the current node as an array.
siblings_of_child1 = child1.siblings

# ..... Lets retrieve immediate children of the root node as an array.
children_of_root = root_node.children

# ..... Retrieve the parent of a node.
parent = child1.parent

# ..... This is a depth-first and L-to-R pre-ordered traversal.
root_node.each { |node| node.content.reverse }

# ..... Lets remove a child node from the root node.
root_node.remove!(child1)
