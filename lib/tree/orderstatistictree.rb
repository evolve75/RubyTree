# orderstatistictree.rb - This file is part of the RubyTree package.
#
# = orderstatistictree.rb - An implementation of the order-statistic tree.
#
# Provides an order-statistic tree (augmented red-black tree) for efficient
# rank and select queries.
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

require_relative 'redblacktree'

module Tree
  # Provides an Order-Statistic Tree implementation. This node allows only two
  # child nodes (left and right child), maintains BST ordering, and stores the
  # subtree size at each node to support rank and select queries.
  #
  # @note The OST key is the node's +content+. A +nil+ content is not allowed
  #   for ordering operations (insert/search/delete). Use a non-nil comparable
  #   value.
  #
  # @note Insert/delete operations can change the root via rotations. If you
  #   retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  class OrderStatisticTreeNode < RedBlackTreeNode
    # @!attribute [r] subtree_size
    # Number of nodes in the subtree rooted at this node.
    attr_reader :subtree_size

    # Create an order-statistic tree node.
    #
    # @param [String, Symbol] name Name of the node.
    # @param [Object] content Content (key) of the node.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    def initialize(name, content = nil, options = nil)
      super
      @subtree_size = content ? 1 : 0
    end

    # Inserts the specified node into the order-statistic tree.
    #
    # @param [Tree::OrderStatisticTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::OrderStatisticTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)

      if root? && @content.nil?
        validate_key!(node.content)
        @content = node.content
        @color = :black
        @subtree_size = 1
        return self
      end

      validate_key!(node.content)
      node.color = :red
      inserted = bst_insert(node)
      fix_insert(inserted)
      root.color = :black if root&.content
      refresh_subtree_size!
      inserted
    end

    # Alias for {#insert} to keep consistency with {Tree::TreeNode#add}.
    #
    # @param [Tree::OrderStatisticTreeNode] child The node to insert.
    # @return [Tree::OrderStatisticTreeNode] The inserted node.
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::OrderStatisticTreeNode, nil] The matching node, or +nil+.
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
    # @return [Tree::OrderStatisticTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      node = search(key)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_node!)
      root.color = :black if root&.content
      refresh_subtree_size!
      removed
    end

    # Returns the OST key for this node (the content).
    #
    # @return [Object] The node content used as the OST key.
    def key
      validate_key!(@content)
      @content
    end

    # Returns the rank of the specified key (zero-based).
    #
    # @param [Object] key The key to rank.
    #
    # @return [Integer, nil] The number of keys smaller than +key+, or +nil+ if missing.
    def rank(key)
      validate_key!(key)
      current = root
      count = 0

      while current
        direction = compare_keys(key, current.key)
        if direction.negative?
          current = current.left_child
        elsif direction.positive?
          count += (current.left_child&.subtree_size || 0) + 1
          current = current.right_child
        else
          return count + (current.left_child&.subtree_size || 0)
        end
      end

      nil
    end

    # Returns the node at the specified rank (zero-based).
    #
    # @param [Integer] index The zero-based rank.
    #
    # @return [Tree::OrderStatisticTreeNode, nil] The node at +index+, or +nil+ if out of range.
    def select(index)
      return nil unless index.is_a?(Integer)
      return nil if index.negative?

      current = root
      remaining = index

      while current
        left_size = current.left_child&.subtree_size || 0
        if remaining < left_size
          current = current.left_child
        elsif remaining == left_size
          return current
        else
          remaining -= left_size + 1
          current = current.right_child
        end
      end

      nil
    end

    # Recompute subtree_size for the subtree rooted at this node.
    #
    # @return [Tree::OrderStatisticTreeNode] The receiver.
    def refresh_subtree_size!
      postordered_each { |node| node.send(:recompute_subtree_size!) }
      self
    end

    private

    # Coerce a name or node into an OST node instance.
    #
    # @param [Tree::OrderStatisticTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::OrderStatisticTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::OrderStatisticTreeNode)
      raise ArgumentError, 'OST nodes must be OrderStatisticTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two OST keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'OST keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'OST key (content) must not be nil.' if key.nil?
    end

    # Recompute subtree_size for this node.
    #
    # @return [void]
    def recompute_subtree_size!
      return @subtree_size = 0 unless @content

      left_size = left_child&.subtree_size || 0
      right_size = right_child&.subtree_size || 0
      @subtree_size = left_size + right_size + 1
    end
  end
end
