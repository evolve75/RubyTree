# bst.rb - This file is part of the RubyTree package.
#
# $Revision$ by $Author$ on $Date$
#
# = bst.rb - An implementation of the binary search tree data structure.
#
# Provides a binary search tree with ability to store two node
# elements as children at each node in the tree.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#

# Copyright (c) 2007, 2008, 2009, 2010 Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
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

require 'tree'

module Tree

  # Provides a Binary Search tree implementation. This node allows
  # only two child nodes (left and right child).  The nodes are added
  # in order as determined by the comparator used during node
  # addition.  By default, the node names are compared.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  # @author Anupam Sengupta
  #
  class BSTNode < BinaryTreeNode

    # Adds the specified child node to the receiver node.  The child
    # node's parent is set to be the receiver.
    #
    # The child nodes are added by comparing using the node names,
    # with the first child's name being ordinally lower than the
    # receiver node's name, and the second child's name being
    # ordinally higher than the receiver node's name. A +nil+ child is
    # considered to be lower than the receiver node.
    #
    # Note that adding a node with the same name is not allowed.
    #
    # @param [Tree::BSTNode] child The child to add.
    #
    # @return [Tree::BSTNode] the added child node.
    #
    # @raise [ArgumentError] This exception is raised if two children
    # are already present, or if the child's node name is same as the
    # receiver node.
    def add(child)
      raise ArgumentError, "Already has two child nodes" if left_child and right_child
      raise ArgumentError, "Attempting to assign same named node ({#child.name})" if child.name == self.name

      # The default comparision is using the node names.
      set_child_at(child, (!child or child.name < self.name) ? 0 : 1)
    end

    # Replaces content of the left child node, provided the node to be
    # added is ordinally lower than the receiver node.
    #
    # By default, the ordinal comparision is performed using name
    # comparision of the child node and the receiver node.
    #
    # @return [Tree::BSTNode] the added child node.
    #
    # @param [Tree::BSTNode] child The child to add.
    #
    # @raise [ArgumentError] if the child node is ordinally higher
    # than the receiver node.
    #
    def left_child=(child)
      raise ArgumentError, "Attempt to add ordinally higher node" if child and child.name >= self.name
      super(child)
    end

    # Replaces content of the right child node, provided the node to
    # be added is ordinally higher than the receiver node.
    #
    # By default, the ordinal comparision is performed using name
    # comparision of the child node and the receiver node.
    #
    # @return [Tree::BSTNode] the added child node.
    #
    # @param [Tree::BSTNode] child The child to add.
    #
    # @raise [ArgumentError] if the child node is ordinally lower
    # than the receiver node.
    #
    def right_child=(child)
      raise ArgumentError, "Attempt to add ordinally lower node" if child and child.name <= self.name
      super(child)
    end

    # This method throws a [RuntimeError] if invoked on a
    # [Tree::BSTNode], as swapping child nodes would otherwise break
    # the order of the nodes.
    #
    # @raise [RuntimeError] always raised for BSTNodes.
    def swap_children
      raise RuntimeError, "Invalid operation for a Binary Search Tree"
      true
    end

  end

end
