# avltree.rb - This file is part of the RubyTree package.
#
# = avltree.rb - An implementation of the AVL tree data structure.
#
# Provides an AVL tree data structure with ordered insert/search/delete
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

module Tree
  # Provides an AVL Tree implementation. This node allows only two child nodes
  # (left and right child), and maintains the BST ordering invariant based on
  # the node content (key) with AVL balancing.
  #
  # @note The AVL key is the node's +content+. A +nil+ content is not allowed for
  #   ordering operations (insert/search/delete). Use a non-nil comparable value.
  #
  # @note Insert/delete operations can change the root via rotations. If you
  #   retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  class AvlTreeNode < BinaryTreeNode
    # @!group Core Attributes

    # @!attribute [r] height
    # Height of this node in the AVL tree.
    attr_reader :height

    # Create an AVL tree node.
    #
    # @param [String, Symbol] name Name of the node.
    # @param [Object] content Content (key) of the node.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    #
    # @see Tree::TreeNode#initialize
    def initialize(name, content = nil, options = nil)
      super
      @height = content.nil? ? 0 : 1
    end

    # Inserts the specified node into the AVL tree, based on the node content.
    #
    # @param [Tree::AvlTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::AvlTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)

      if root? && @content.nil?
        validate_key!(node.content)
        @content = node.content
        @height = 1
        return self
      end

      inserted = bst_insert(node)
      rebalance_upwards(inserted.parent)
      inserted
    end

    # Alias for {#insert} to keep consistency with {Tree::TreeNode#add}.
    #
    # This overrides {Tree::TreeNode#add}; the +at_index+ parameter is ignored
    # because AVL nodes are inserted according to key ordering.
    #
    # @param [Tree::AvlTreeNode] child The node to insert.
    # @return [Tree::AvlTreeNode] The inserted node.
    #
    # @see Tree::TreeNode#add
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::AvlTreeNode, nil] The matching node, or +nil+.
    def search(key)
      validate_key!(key)
      return nil if root? && @content.nil?

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
    # @return [Tree::AvlTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      validate_key!(key)
      return nil if root? && @content.nil?

      node = search(key)
      return nil unless node

      removed = node.detached_copy
      rebalance_start = node.send(:delete_node!)
      rebalance_upwards(rebalance_start)
      removed
    end

    # Returns the minimum node in the subtree rooted at this node.
    #
    # @return [Tree::AvlTreeNode] The minimum node in the subtree.
    def min_node
      current = self
      current = current.left_child while current.left_child
      current
    end

    # Returns the maximum node in the subtree rooted at this node.
    #
    # @return [Tree::AvlTreeNode] The maximum node in the subtree.
    def max_node
      current = self
      current = current.right_child while current.right_child
      current
    end

    # Returns the AVL key for this node (the content).
    #
    # @return [Object] The node content used as the AVL key.
    def key
      validate_key!(@content)
      @content
    end

    private

    # Coerce a name or node into an AVL node instance.
    #
    # @param [Tree::AvlTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::AvlTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::AvlTreeNode)
      raise ArgumentError, 'AVL nodes must be AvlTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two AVL keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'AVL keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'AVL key (content) must not be nil.' if key.nil?
    end

    # Insert a node using BST ordering (no balancing).
    #
    # @param [Tree::AvlTreeNode] node The node to insert.
    # @return [Tree::AvlTreeNode] The inserted node.
    def bst_insert(node)
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

    # Delete the receiver node from the tree.
    #
    # @return [Tree::AvlTreeNode] Node to begin rebalancing from.
    def delete_node!
      return delete_with_two_children! if left_child && right_child

      if root?
        return delete_root_leaf! unless (child = left_child || right_child)

        return delete_root_with_child!(child)
      end

      delete_non_root!(left_child || right_child)
    end

    # Rebalance ancestors starting from the specified node.
    #
    # @param [Tree::AvlTreeNode, nil] node The starting node.
    # @return [void]
    def rebalance_upwards(node)
      current = node
      while current
        update_height!(current)
        current = rebalance(current).parent
      end
    end

    # Rebalance a node and return the subtree root after rebalancing.
    #
    # @param [Tree::AvlTreeNode] node The node to rebalance.
    # @return [Tree::AvlTreeNode] The new subtree root.
    def rebalance(node)
      balance = balance_factor(node)

      if balance > 1
        rotate_left(node.left_child) if balance_factor(node.left_child).negative?
        return rotate_right(node)
      end

      if balance < -1
        rotate_right(node.right_child) if balance_factor(node.right_child).positive?
        return rotate_left(node)
      end

      node
    end

    # Compute the balance factor for a node.
    #
    # @param [Tree::AvlTreeNode, nil] node The node to measure.
    # @return [Integer] The balance factor.
    def balance_factor(node)
      height_of(node&.left_child) - height_of(node&.right_child)
    end

    # Return the height for a node (nil nodes have height 0).
    #
    # @param [Tree::AvlTreeNode, nil] node The node to measure.
    # @return [Integer] The node height.
    def height_of(node)
      node&.height.to_i
    end

    # Update the height of a node based on its children.
    #
    # @param [Tree::AvlTreeNode] node The node to update.
    # @return [void]
    def update_height!(node)
      if node.content.nil?
        node.instance_variable_set(:@height, 0)
        return
      end

      node_height = 1 + [height_of(node.left_child), height_of(node.right_child)].max
      node.instance_variable_set(:@height, node_height)
    end

    # Perform a left rotation around the specified node.
    #
    # @param [Tree::AvlTreeNode] node The rotation pivot.
    # @return [Tree::AvlTreeNode] The new subtree root.
    def rotate_left(node)
      pivot = node.right_child
      return node unless pivot

      node.right_child = pivot.left_child

      if node.root?
        pivot.send(:parent=, nil)
      elsif node.left_child?
        node.parent.left_child = pivot
      else
        node.parent.right_child = pivot
      end

      pivot.left_child = node
      update_height!(node)
      update_height!(pivot)
      pivot
    end

    # Perform a right rotation around the specified node.
    #
    # @param [Tree::AvlTreeNode] node The rotation pivot.
    # @return [Tree::AvlTreeNode] The new subtree root.
    def rotate_right(node)
      pivot = node.left_child
      return node unless pivot

      node.left_child = pivot.right_child

      if node.root?
        pivot.send(:parent=, nil)
      elsif node.right_child?
        node.parent.right_child = pivot
      else
        node.parent.left_child = pivot
      end

      pivot.right_child = node
      update_height!(node)
      update_height!(pivot)
      pivot
    end

    # Delete a node with two children by replacing it with the successor.
    #
    # @return [Tree::AvlTreeNode] Node to begin rebalancing from.
    def delete_with_two_children!
      successor = right_child.min_node
      @content = successor.content
      successor.send(:delete_node!)
    end

    # Delete a root node that has a single child.
    #
    # @param [Tree::AvlTreeNode] child The only child.
    # @return [Tree::AvlTreeNode] Node to begin rebalancing from.
    def delete_root_with_child!(child)
      left = child.left_child
      right = child.right_child
      @content = child.content
      @children = []
      @children_hash = {}
      self.left_child = left if left
      self.right_child = right if right
      child.set_as_root!
      update_height!(self)
      self
    end

    # Delete a root node that has no children.
    #
    # @return [Tree::AvlTreeNode] Node to begin rebalancing from.
    def delete_root_leaf!
      @content = nil
      @height = 0
      self
    end

    # Delete a non-root node and return the parent to rebalance from.
    #
    # @param [Tree::AvlTreeNode, nil] child The child to replace the node.
    # @return [Tree::AvlTreeNode] Node to begin rebalancing from.
    def delete_non_root!(child)
      parent_node = parent
      if left_child?
        parent.left_child = child
      else
        parent.right_child = child
      end

      set_as_root!
      parent_node
    end
  end
end
