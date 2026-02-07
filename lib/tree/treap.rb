# treap.rb - This file is part of the RubyTree package.
#
# = treap.rb - An implementation of the treap data structure.
#
# Provides a treap (BST + heap) data structure with ordered insert/search/delete
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
  # Provides a Treap implementation. This node allows only two child nodes
  # (left and right child), and maintains the BST ordering invariant based on
  # the node content (key) with heap ordering by priority.
  #
  # This treap uses a min-heap priority ordering. Lower priority values are
  # closer to the root.
  #
  # @note The treap key is the node's +content+. A +nil+ content is not allowed
  #   for ordering operations (insert/search/delete). Use a non-nil comparable
  #   value.
  #
  # @note Insert/delete operations can change the root via rotations. If you
  #   retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  class TreapNode < BinaryTreeNode
    # @!group Core Attributes

    # @!attribute [r] priority
    # Heap priority of the node. Lower values have higher priority.
    attr_reader :priority

    # Create a treap node.
    #
    # @param [String, Symbol] name Name of the node.
    # @param [Object] content Content (key) of the node.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    # @param [Numeric, nil] priority Explicit priority value.
    #
    # @see Tree::TreeNode#initialize
    def initialize(name, content = nil, options = nil, priority: nil)
      super(name, content, options)
      @priority = priority || generate_priority
    end

    # Inserts the specified node into the treap, based on the node content.
    #
    # @param [Tree::TreapNode, String, Symbol] node_or_name The node instance to
    #   insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    # @param [Numeric, nil] priority Explicit priority value for a new node.
    #
    # @return [Tree::TreapNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    #
    # @note Insertions always start from the current root to preserve treap
    #   ordering if rotations have changed the root.
    def insert(node_or_name, content = nil, priority: nil)
      node = coerce_node(node_or_name, content, priority)
      tree_root = root

      if tree_root.root? && tree_root.content.nil?
        validate_key!(node.content)
        tree_root.instance_variable_set(:@content, node.content)
        tree_root.instance_variable_set(:@priority, node.priority)
        return tree_root
      end

      inserted = tree_root.send(:bst_insert, node)
      heapify_up(inserted)
      inserted
    end

    # Alias for {#insert} to keep consistency with Tree::TreeNode#add.
    #
    # This overrides Tree::TreeNode#add; the +at_index+ parameter is ignored
    # because treap nodes are inserted according to key ordering.
    #
    # @param [Tree::TreapNode] child The node to insert.
    # @return [Tree::TreapNode] The inserted node.
    #
    # @see Tree::TreeNode#add
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::TreapNode, nil] The matching node, or +nil+.
    #
    # @note Searches always start from the current root.
    def search(key)
      validate_key!(key)
      tree_root = root
      return nil if tree_root.root? && tree_root.content.nil?

      current = tree_root
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
    # @return [Tree::TreapNode, nil] The removed node, or +nil+ if not found.
    #
    # @note Deletions always start from the current root.
    def delete(key)
      validate_key!(key)
      tree_root = root
      return nil if tree_root.root? && tree_root.content.nil?

      node = tree_root.search(key)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_node!)
      removed
    end

    # Returns the minimum node in the subtree rooted at this node.
    #
    # @return [Tree::TreapNode] The minimum node in the subtree.
    def min_node
      current = self
      current = current.left_child while current.left_child
      current
    end

    # Returns the maximum node in the subtree rooted at this node.
    #
    # @return [Tree::TreapNode] The maximum node in the subtree.
    def max_node
      current = self
      current = current.right_child while current.right_child
      current
    end

    # Returns the treap key for this node (the content).
    #
    # @return [Object] The node content used as the treap key.
    def key
      validate_key!(@content)
      @content
    end

    private

    # Generate a random priority value.
    #
    # @return [Integer] A priority value.
    def generate_priority
      rand(1..1_000_000_000)
    end

    # Coerce a name or node into a treap node instance.
    #
    # @param [Tree::TreapNode, String, Symbol] node_or_name The node instance to
    #   insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @param [Numeric, nil] priority Explicit priority value for a new node.
    # @return [Tree::TreapNode] A node instance.
    def coerce_node(node_or_name, content, priority)
      return node_or_name if node_or_name.is_a?(Tree::TreapNode)
      raise ArgumentError, 'Treap nodes must be TreapNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? }, priority: priority)
    end

    # Compare two treap keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'Treap keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'Treap key (content) must not be nil.' if key.nil?
    end

    # Insert a node using BST ordering (no heap balancing).
    #
    # @param [Tree::TreapNode] node The node to insert.
    # @return [Tree::TreapNode] The inserted node.
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

    # Restore heap ordering by rotating the node upwards.
    #
    # @param [Tree::TreapNode] node The node to lift.
    # @return [void]
    def heapify_up(node)
      current = node
      while current.parent && current.priority < current.parent.priority
        if current.left_child?
          rotate_right(current.parent)
        else
          rotate_left(current.parent)
        end
      end
    end

    # Delete the receiver node from the tree.
    #
    # @return [void]
    def delete_node!
      return reset_empty_root if root? && @content.nil?

      current = rotate_down_to_leaf(self)
      remove_leaf(current)
    end

    # Perform a left rotation around the specified node.
    #
    # @param [Tree::TreapNode] node The rotation pivot.
    # @return [Tree::TreapNode] The new subtree root.
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
      pivot
    end

    # Perform a right rotation around the specified node.
    #
    # @param [Tree::TreapNode] node The rotation pivot.
    # @return [Tree::TreapNode] The new subtree root.
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
      pivot
    end

    # Reset an empty root node after delete attempts.
    #
    # @return [void]
    def reset_empty_root
      @priority = generate_priority
    end

    # Rotate a node down until it becomes a leaf.
    #
    # @param [Tree::TreapNode] node The node to rotate down.
    # @return [Tree::TreapNode] The leaf node after rotations.
    def rotate_down_to_leaf(node)
      current = node
      rotate_down_once(current) while current.left_child || current.right_child
      current
    end

    # Perform a single rotation step to move the node down.
    #
    # @param [Tree::TreapNode] node The node to rotate down.
    # @return [void]
    def rotate_down_once(node)
      if node.left_child && node.right_child
        if node.left_child.priority < node.right_child.priority
          rotate_right(node)
        else
          rotate_left(node)
        end
      elsif node.left_child
        rotate_right(node)
      else
        rotate_left(node)
      end
    end

    # Remove a leaf node from the treap.
    #
    # @param [Tree::TreapNode] node The leaf node to remove.
    # @return [void]
    def remove_leaf(node)
      if node.root?
        @content = nil
        @priority = generate_priority
        return
      end

      if node.left_child?
        node.parent.left_child = nil
      else
        node.parent.right_child = nil
      end
    end
  end
end
