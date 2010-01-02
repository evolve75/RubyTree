# binarytree.rb
#
# $Revision$ by $Author$ on $Date$
#
# = binarytree.rb - Binary Tree implementation
#
# Provides a generic tree data structure with ability to
# store keyed node elements in the tree. The implementation
# mixes in the Enumerable module.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#

# Copyright (c) 2007 Anupam Sengupta
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

  # Provides a Binary tree implementation. This tree node allows only two child
  # nodes (left and right childs). It also provides direct access to the left
  # and right children, including assignment to the same.
  class BinaryTreeNode < TreeNode

    # Adds the specified child node to the receiver node.  The child node's
    # parent is set to be the receiver.  The child nodes are added in the order
    # of addition, i.e., the first child added becomes the left node, and the
    # second child will be the second node.
    # If only one child is present, then this will be the left child.
    def add(child)
      raise "Already has two child nodes" if @children.size == 2

      super(child)
    end

    # Returns the left child node. Note that
    # left Child == first Child
    def leftChild
      children.first
    end

    # Returns the right child node. Note that
    # right child == last child unless there is only one child.
    # Returns nil if the right child does not exist.
    def rightChild
      children[1]
    end

    # Sets the left child. If a previous child existed, it is replaced.
    def leftChild=(child)
      @children[0] = child
      @childrenHash[child.name] = child if child # Assign the name mapping
    end

    # Sets the right child. If a previous child existed, it is replaced.
    def rightChild=(child)
      @children[1] = child
      @childrenHash[child.name] = child if child # Assign the name mapping
    end

    # Returns true if this is the left child of its parent. Always returns false
    # if this is the root node.
    def isLeftChild?
      return nil if isRoot?
      self == parent.leftChild
    end

    # Returns true if this is the right child of its parent. Always returns false
    # if this is the root node.
    def isRightChild?
      return nil if isRoot?
      self == parent.rightChild
    end

    # Swaps the left and right children with each other
    def swap_children
      tempChild = leftChild
      self.leftChild= rightChild
      self.rightChild= tempChild
    end
  end

end
