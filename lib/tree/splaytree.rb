# splaytree.rb - This file is part of the RubyTree package.
#
# = splaytree.rb - An implementation of the splay tree data structure.
#
# Provides a splay tree data structure with ordered insert/search/delete
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
  # Provides a Splay Tree implementation. This node allows only two child nodes
  # (left and right child), and maintains the BST ordering invariant based on
  # the node content (key) with splaying on access and updates.
  #
  # @note The splay key is the node's +content+. A +nil+ content is not allowed
  #   for ordering operations (insert/search/delete). Use a non-nil comparable
  #   value.
  #
  # @note Insert/delete/search operations can change the root via rotations. If
  #   you retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  class SplayTreeNode < BinaryTreeNode
    # Inserts the specified node into the splay tree, based on the node content.
    #
    # @param [Tree::SplayTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::SplayTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)
      tree_root = root

      if tree_root.root? && tree_root.content.nil?
        validate_key!(node.content)
        tree_root.instance_variable_set(:@content, node.content)
        return tree_root
      end

      inserted = tree_root.send(:bst_insert, node)
      tree_root.send(:splay, inserted)
      inserted
    end

    # Alias for {#insert} to keep consistency with Tree::TreeNode#add.
    #
    # This overrides Tree::TreeNode#add; the +at_index+ parameter is ignored
    # because splay nodes are inserted according to key ordering.
    #
    # @param [Tree::SplayTreeNode] child The node to insert.
    # @return [Tree::SplayTreeNode] The inserted node.
    #
    # @see Tree::TreeNode#add
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::SplayTreeNode, nil] The matching node, or +nil+.
    def search(key)
      validate_key!(key)
      tree_root = root
      return nil if tree_root.root? && tree_root.content.nil?

      current = tree_root
      last = nil
      while current
        last = current
        direction = compare_keys(key, current.key)
        if direction.zero?
          tree_root.send(:splay, current)
          return current
        end
        current = direction.negative? ? current.left_child : current.right_child
      end

      tree_root.send(:splay, last) if last
      nil
    end

    # Deletes the node matching the specified key (content).
    #
    # @param [Object] key The key to delete.
    #
    # @return [Tree::SplayTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      validate_key!(key)
      tree_root = root
      return nil if tree_root.root? && tree_root.content.nil?

      node = tree_root.search(key)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_root!)
      removed
    end

    # Returns the minimum node in the subtree rooted at this node.
    #
    # @return [Tree::SplayTreeNode] The minimum node in the subtree.
    def min_node
      current = self
      current = current.left_child while current.left_child
      current
    end

    # Returns the maximum node in the subtree rooted at this node.
    #
    # @return [Tree::SplayTreeNode] The maximum node in the subtree.
    def max_node
      current = self
      current = current.right_child while current.right_child
      current
    end

    # Returns the splay key for this node (the content).
    #
    # @return [Object] The node content used as the splay key.
    def key
      validate_key!(@content)
      @content
    end

    private

    # Coerce a name or node into a splay node instance.
    #
    # @param [Tree::SplayTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::SplayTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::SplayTreeNode)
      raise ArgumentError, 'Splay nodes must be SplayTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two splay keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'Splay keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'Splay key (content) must not be nil.' if key.nil?
    end

    # Insert a node using BST ordering (no splaying).
    #
    # @param [Tree::SplayTreeNode] node The node to insert.
    # @return [Tree::SplayTreeNode] The inserted node.
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

    # Splay the node to the root of the tree.
    #
    # @param [Tree::SplayTreeNode] node The node to splay.
    # @return [void]
    def splay(node)
      current = node
      while current.parent
        if current.parent.root?
          rotate_once(current)
        else
          rotate_twice(current)
        end
      end
    end

    # Rotate a node once (zig step).
    #
    # @param [Tree::SplayTreeNode] node The node to rotate.
    # @return [void]
    def rotate_once(node)
      if node.left_child?
        rotate_right(node.parent)
      else
        rotate_left(node.parent)
      end
    end

    # Rotate a node twice (zig-zig or zig-zag).
    #
    # @param [Tree::SplayTreeNode] node The node to rotate.
    # @return [void]
    def rotate_twice(node)
      parent = node.parent
      grandparent = parent.parent

      if node.left_child? && parent.left_child?
        rotate_right(grandparent)
        rotate_right(parent)
      elsif node.right_child? && parent.right_child?
        rotate_left(grandparent)
        rotate_left(parent)
      elsif node.left_child? && parent.right_child?
        rotate_right(parent)
        rotate_left(grandparent)
      else
        rotate_left(parent)
        rotate_right(grandparent)
      end
    end

    # Delete the current root node from the tree.
    #
    # @return [void]
    def delete_root!
      left = left_child
      right = right_child

      if left.nil? && right.nil?
        @content = nil
        return
      end

      left&.send(:set_as_root!)
      right&.send(:set_as_root!)

      if left.nil?
        right.send(:set_as_root!)
        return
      end

      max = left.max_node
      left.send(:splay, max)
      max.right_child = right if right
    end

    # Perform a left rotation around the specified node.
    #
    # @param [Tree::SplayTreeNode] node The rotation pivot.
    # @return [Tree::SplayTreeNode] The new subtree root.
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
    # @param [Tree::SplayTreeNode] node The rotation pivot.
    # @return [Tree::SplayTreeNode] The new subtree root.
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
  end
end
