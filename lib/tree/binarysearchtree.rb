# binarysearchtree.rb - This file is part of the RubyTree package.
#
# = binarysearchtree.rb - An implementation of the binary search tree data structure.
#
# Provides a binary search tree (BST) data structure with ordered insert/search
# operations based on node content.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
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
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

require_relative 'binarytree'
require_relative 'utils/binary_search_node_accessors'

module Tree
  # Provides a Binary Search Tree (BST) implementation. This node allows only
  # two child nodes (left and right child), and maintains the BST ordering
  # invariant based on the node content (key).
  #
  # @note The BST key is the node's +content+. A +nil+ content is not allowed for
  #   ordering operations (insert/search/delete). Use a non-nil comparable value.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  class BinarySearchTreeNode < BinaryTreeNode
    include Tree::Utils::BinarySearchNodeAccessors

    # Inserts the specified node into the BST, based on the node content.
    #
    # @param [Tree::BinarySearchTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::BinarySearchTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)

      if root? && @content.nil?
        validate_key!(node.content)
        @content = node.content
        return self
      end

      current = self

      loop do
        direction = compare_keys(node.key, current.key)

        if direction.negative?
          if current.left_child
            current = current.left_child
          else
            current.left_child = node
            return node
          end
        elsif current.right_child
          current = current.right_child
        else
          current.right_child = node
          return node
        end
      end
    end

    # Alias for {#insert} to keep consistency with {Tree::TreeNode#add}.
    #
    # @param [Tree::BinarySearchTreeNode] child The node to insert.
    # @return [Tree::BinarySearchTreeNode] The inserted node.
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::BinarySearchTreeNode, nil] The matching node, or +nil+.
    def search(key)
      validate_key!(key)

      current = self
      while current
        direction = compare_keys(key, current.key)
        return current if direction.zero?

        current = direction.negative? ? current.left_child : current.right_child
      end

      nil
    end

    # Deletes the node matching the specified key (content).
    #
    # @param [Object] key The key to delete.
    #
    # @return [Tree::BinarySearchTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      node = search(key)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_node!)
      removed
    end

    private

    # Coerce a name or node into a BST node instance.
    #
    # @param [Tree::BinarySearchTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::BinarySearchTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::BinarySearchTreeNode)
      raise ArgumentError, 'BST nodes must be BinarySearchTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two BST keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'BST keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'BST key (content) must not be nil.' if key.nil?
    end

    # Delete the receiver node from the tree.
    #
    # @return [Tree::BinarySearchTreeNode] The receiver node.
    def delete_node!
      if left_child && right_child
        delete_with_two_children!
        return self
      end

      if root?
        delete_root_with_single_or_no_child!
        return self
      end

      delete_non_root_with_single_or_no_child!
      self
    end

    # Delete a node with two children by replacing with the in-order successor.
    #
    # @return [void]
    def delete_with_two_children!
      successor = right_child.min_node
      @content = successor.content
      successor.send(:delete_node!)
    end

    # Delete a root node with a single child or no children.
    #
    # @return [void]
    def delete_root_with_single_or_no_child!
      child = left_child || right_child
      if child
        left = child.left_child
        right = child.right_child
        @content = child.content
        @children = []
        @children_hash = {}
        self.left_child = left if left
        self.right_child = right if right
        child.set_as_root!
      else
        @content = nil
      end
    end

    # Delete a non-root node with a single child or no children.
    #
    # @return [void]
    def delete_non_root_with_single_or_no_child!
      child = left_child || right_child
      if left_child?
        parent.left_child = child
      else
        parent.right_child = child
      end

      set_as_root!
    end
  end
end
