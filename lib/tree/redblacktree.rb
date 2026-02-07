# redblacktree.rb - This file is part of the RubyTree package.
#
# = redblacktree.rb - An implementation of the red-black tree data structure.
#
# Provides a red-black tree data structure with ordered insert/search/delete
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
  # Provides a Red-Black Tree implementation. This node allows only two child
  # nodes (left and right child), and maintains the BST ordering invariant based
  # on the node content (key) with red-black balancing.
  #
  # @note The RB tree key is the node's +content+. A +nil+ content is not allowed
  #   for ordering operations (insert/search/delete). Use a non-nil comparable
  #   value.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  # @note Insert/delete operations can change the root via rotations. If you
  #   retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  class RedBlackTreeNode < BinaryTreeNode
    # @!group Core Attributes

    # @!attribute [r] color
    # Color of the node (:red or :black).
    attr_reader :color

    # Create a red-black tree node.
    #
    # @param [String, Symbol] name Name of the node.
    # @param [Object] content Content (key) of the node.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    def initialize(name, content = nil, options = nil)
      super
      @color = :black
    end

    # Returns +true+ if the node is red.
    #
    # @return [Boolean] +true+ if this node is red.
    def red?
      @color == :red
    end

    # Returns +true+ if the node is black.
    #
    # @return [Boolean] +true+ if this node is black.
    def black?
      @color == :black
    end

    # Inserts the specified node into the RB tree, based on the node content.
    #
    # @param [Tree::RedBlackTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::RedBlackTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)

      if root? && @content.nil?
        validate_key!(node.content)
        @content = node.content
        @color = :black
        return self
      end

      node.color = :red
      inserted = bst_insert(node)
      fix_insert(inserted)
      root.color = :black if root&.content
      inserted
    end

    # Alias for {#insert} to keep consistency with {Tree::TreeNode#add}.
    #
    # @param [Tree::RedBlackTreeNode] child The node to insert.
    # @return [Tree::RedBlackTreeNode] The inserted node.
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::RedBlackTreeNode, nil] The matching node, or +nil+.
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
    # @return [Tree::RedBlackTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      node = search(key)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_node!)
      root.color = :black if root&.content
      removed
    end

    # Returns the minimum node in the subtree rooted at this node.
    #
    # @return [Tree::RedBlackTreeNode] The minimum node in the subtree.
    def min_node
      current = self
      current = current.left_child while current.left_child
      current
    end

    # Returns the maximum node in the subtree rooted at this node.
    #
    # @return [Tree::RedBlackTreeNode] The maximum node in the subtree.
    def max_node
      current = self
      current = current.right_child while current.right_child
      current
    end

    # Returns the RB tree key for this node (the content).
    #
    # @return [Object] The node content used as the RB tree key.
    def key
      validate_key!(@content)
      @content
    end

    protected

    # Sets the node color.
    #
    # @param [Symbol] value The color (:red or :black).
    def color=(value)
      raise ArgumentError, "Invalid color: #{value} (expected :red or :black)" unless %i[red black].include?(value)

      @color = value
    end

    private

    # Coerce a name or node into an RB tree node instance.
    #
    # @param [Tree::RedBlackTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::RedBlackTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::RedBlackTreeNode)
      raise ArgumentError, 'RB nodes must be RedBlackTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two RB keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'RB keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'RB key (content) must not be nil.' if key.nil?
    end

    # Insert a node using BST ordering (no balancing).
    #
    # @param [Tree::RedBlackTreeNode] node The node to insert.
    # @return [Tree::RedBlackTreeNode] The inserted node.
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

    # Fix the tree after insertion to restore RB invariants.
    #
    # @param [Tree::RedBlackTreeNode] node The inserted node.
    # @return [void]
    def fix_insert(node)
      current = node

      while current.parent&.red?
        current =
          if current.parent.left_child?
            fix_insert_left(current)
          else
            fix_insert_right(current)
          end
      end
    end

    # Delete the receiver node from the tree.
    #
    # @return [Tree::RedBlackTreeNode] The receiver node.
    def delete_node!
      return delete_root! if root?

      delete_non_root!
    end

    # Delete a root node, preserving the root object.
    #
    # @return [Tree::RedBlackTreeNode] The receiver node.
    def delete_root!
      if left_child && right_child
        delete_root_with_two_children!
      elsif left_child || right_child
        delete_root_with_single_child!
      else
        delete_root_leaf!
      end

      @color = :black if @content
      self
    end

    # Delete a non-root node, preserving RB invariants.
    #
    # @return [Tree::RedBlackTreeNode] The receiver node.
    def delete_non_root!
      y = self
      y_original_color = y.color
      x = nil
      x_parent = nil

      if left_child.nil?
        x = right_child
        x_parent = parent
        replace_node(self, right_child)
      elsif right_child.nil?
        x = left_child
        x_parent = parent
        replace_node(self, left_child)
      else
        y = right_child.min_node
        y_original_color = y.color
        x = y.right_child
        if y.parent.equal?(self)
          x_parent = y
        else
          x_parent = y.parent
          replace_node(y, y.right_child)
          y.right_child = right_child
        end
        replace_node(self, y)
        y.left_child = left_child
        y.color = color
      end

      fix_delete(x, x_parent) if y_original_color == :black
      self
    end

    # Replace a node with another node in the tree (non-root only).
    #
    # @param [Tree::RedBlackTreeNode] node The node to replace.
    # @param [Tree::RedBlackTreeNode, nil] replacement The replacement node.
    # @return [Tree::RedBlackTreeNode] The replaced node.
    def replace_node(node, replacement)
      if node.left_child?
        node.parent.left_child = replacement
      else
        node.parent.right_child = replacement
      end
      node.set_as_root!
      node
    end

    # Fix the tree after deletion to restore RB invariants.
    #
    # @param [Tree::RedBlackTreeNode, nil] node The subtree root to fix.
    # @param [Tree::RedBlackTreeNode, nil] parent The parent of +node+ when +node+ is nil.
    # @return [void]
    def fix_delete(node, parent)
      current = node
      current_parent = parent
      root_node = root

      while current != root_node && color_of(current) == :black
        break unless current_parent

        if current == current_parent.left_child
          current, current_parent = fix_delete_left(current, current_parent, root_node)
        else
          current, current_parent = fix_delete_right(current, current_parent, root_node)
        end
      end

      current.color = :black if current
    end

    # Fix insertion when the parent is a left child.
    #
    # @param [Tree::RedBlackTreeNode] current The current node.
    # @return [Tree::RedBlackTreeNode] The node to continue fixing from.
    def fix_insert_left(current)
      uncle = current.parent.parent&.right_child
      if color_of(uncle) == :red
        recolor_insert_relatives(current.parent, uncle)
        current.parent.parent.color = :red
        return current.parent.parent
      end

      if current.right_child?
        current = current.parent
        rotate_left(current)
      end
      current.parent.color = :black
      current.parent.parent.color = :red
      rotate_right(current.parent.parent)
      current
    end

    # Fix insertion when the parent is a right child.
    #
    # @param [Tree::RedBlackTreeNode] current The current node.
    # @return [Tree::RedBlackTreeNode] The node to continue fixing from.
    def fix_insert_right(current)
      uncle = current.parent.parent&.left_child
      if color_of(uncle) == :red
        recolor_insert_relatives(current.parent, uncle)
        current.parent.parent.color = :red
        return current.parent.parent
      end

      if current.left_child?
        current = current.parent
        rotate_right(current)
      end
      current.parent.color = :black
      current.parent.parent.color = :red
      rotate_left(current.parent.parent)
      current
    end

    # Recolor a parent and its uncle during insert fixup.
    #
    # @param [Tree::RedBlackTreeNode] parent The parent node.
    # @param [Tree::RedBlackTreeNode, nil] uncle The uncle node.
    # @return [void]
    def recolor_insert_relatives(parent, uncle)
      parent.color = :black
      uncle.color = :black if uncle
    end

    # Delete a root node that has two children.
    #
    # @return [void]
    def delete_root_with_two_children!
      successor = right_child.min_node
      successor_color = successor.color
      successor_content = successor.content
      successor.send(:delete_node!)
      @content = successor_content
      @color = successor_color
    end

    # Delete a root node that has one child.
    #
    # @return [void]
    def delete_root_with_single_child!
      child = left_child || right_child
      @content = child.content
      @color = child.color
      @children = []
      @children_hash = {}
      self.left_child = child.left_child if child.left_child
      self.right_child = child.right_child if child.right_child
      child.set_as_root!
    end

    # Delete a root node that has no children.
    #
    # @return [void]
    def delete_root_leaf!
      @content = nil
    end

    # Fix deletion when the removed node was a left child.
    #
    # @param [Tree::RedBlackTreeNode, nil] current The current node.
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode] root_node The tree root.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_left(current, parent, root_node)
      sibling = parent.right_child
      sibling = fix_delete_left_red_sibling(parent, sibling)

      return fix_delete_left_black_children(current, parent, sibling) if sibling_black_children?(sibling)

      sibling = fix_delete_left_prepare_outer(parent, sibling) if color_of(sibling&.right_child) == :black

      fix_delete_left_final(parent, sibling, root_node)
    end

    # Fix deletion when the removed node was a right child.
    #
    # @param [Tree::RedBlackTreeNode, nil] current The current node.
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode] root_node The tree root.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_right(current, parent, root_node)
      sibling = parent.left_child
      sibling = fix_delete_right_red_sibling(parent, sibling)

      return fix_delete_right_black_children(current, parent, sibling) if sibling_black_children?(sibling)

      sibling = fix_delete_right_prepare_outer(parent, sibling) if color_of(sibling&.left_child) == :black

      fix_delete_right_final(parent, sibling, root_node)
    end

    # Returns +true+ if both children of the sibling are black (or nil).
    #
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Boolean] +true+ when both sibling children are black.
    def sibling_black_children?(sibling)
      color_of(sibling&.left_child) == :black && color_of(sibling&.right_child) == :black
    end

    # Handle a red sibling on the left-delete path.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Tree::RedBlackTreeNode, nil] The updated sibling node.
    def fix_delete_left_red_sibling(parent, sibling)
      return sibling unless color_of(sibling) == :red

      sibling.color = :black
      parent.color = :red
      rotate_left(parent)
      parent.right_child
    end

    # Handle a red sibling on the right-delete path.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Tree::RedBlackTreeNode, nil] The updated sibling node.
    def fix_delete_right_red_sibling(parent, sibling)
      return sibling unless color_of(sibling) == :red

      sibling.color = :black
      parent.color = :red
      rotate_right(parent)
      parent.left_child
    end

    # Handle the black-children sibling case on the left-delete path.
    #
    # @param [Tree::RedBlackTreeNode, nil] current The current node.
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_left_black_children(_current, parent, sibling)
      sibling.color = :red if sibling
      current = parent
      [current, current.parent]
    end

    # Handle the black-children sibling case on the right-delete path.
    #
    # @param [Tree::RedBlackTreeNode, nil] current The current node.
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_right_black_children(_current, parent, sibling)
      sibling.color = :red if sibling
      current = parent
      [current, current.parent]
    end

    # Prepare the left-delete path when the outer child is black.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Tree::RedBlackTreeNode, nil] The updated sibling node.
    def fix_delete_left_prepare_outer(parent, sibling)
      sibling.left_child.color = :black if sibling&.left_child
      sibling.color = :red if sibling
      rotate_right(sibling)
      parent.right_child
    end

    # Prepare the right-delete path when the outer child is black.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @return [Tree::RedBlackTreeNode, nil] The updated sibling node.
    def fix_delete_right_prepare_outer(parent, sibling)
      sibling.right_child.color = :black if sibling&.right_child
      sibling.color = :red if sibling
      rotate_left(sibling)
      parent.left_child
    end

    # Finalize the left-delete path by recoloring and rotating.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @param [Tree::RedBlackTreeNode] root_node The tree root.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_left_final(parent, sibling, root_node)
      sibling.color = parent.color if sibling
      parent.color = :black
      sibling.right_child.color = :black if sibling&.right_child
      rotate_left(parent)
      [root_node, root_node.parent]
    end

    # Finalize the right-delete path by recoloring and rotating.
    #
    # @param [Tree::RedBlackTreeNode] parent The current parent.
    # @param [Tree::RedBlackTreeNode, nil] sibling The sibling node.
    # @param [Tree::RedBlackTreeNode] root_node The tree root.
    # @return [Array<Tree::RedBlackTreeNode, Tree::RedBlackTreeNode>] New current and parent.
    def fix_delete_right_final(parent, sibling, root_node)
      sibling.color = parent.color if sibling
      parent.color = :black
      sibling.left_child.color = :black if sibling&.left_child
      rotate_right(parent)
      [root_node, root_node.parent]
    end

    # Perform a left rotation around the specified node.
    #
    # @param [Tree::RedBlackTreeNode] node The rotation pivot.
    # @return [void]
    def rotate_left(node)
      pivot = node.right_child
      return unless pivot

      node.right_child = pivot.left_child

      if node.root?
        pivot.send(:parent=, nil)
      elsif node.left_child?
        node.parent.left_child = pivot
      else
        node.parent.right_child = pivot
      end

      pivot.left_child = node
    end

    # Perform a right rotation around the specified node.
    #
    # @param [Tree::RedBlackTreeNode] node The rotation pivot.
    # @return [void]
    def rotate_right(node)
      pivot = node.left_child
      return unless pivot

      node.left_child = pivot.right_child

      if node.root?
        pivot.send(:parent=, nil)
      elsif node.right_child?
        node.parent.right_child = pivot
      else
        node.parent.left_child = pivot
      end

      pivot.right_child = node
    end

    # Return the color for a node (nil nodes are black).
    #
    # @param [Tree::RedBlackTreeNode, nil] node The node to inspect.
    # @return [Symbol] :red or :black.
    def color_of(node)
      node&.color || :black
    end
  end
end
