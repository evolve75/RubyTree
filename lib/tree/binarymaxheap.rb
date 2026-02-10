# binarymaxheap.rb - This file is part of the RubyTree package.
#
# = binarymaxheap.rb - An implementation of the binary max-heap data structure.
#
# Provides a binary max-heap data structure with ordered insert/extract
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
require_relative 'utils/heap_shared_methods'

module Tree
  # Provides a Binary Max-Heap implementation. This node allows only two child
  # nodes (left and right child), and maintains the heap ordering invariant
  # based on the node content (key).
  #
  # The heap is a max-heap: higher values are closer to the root.
  #
  # @note The heap key is the node's +content+. A +nil+ content is not allowed
  #   for ordering operations (insert/search/delete). Use a non-nil comparable
  #   value.
  #
  # @note Insert/extract operations can change the root *content* by swapping
  #   values. The root node object remains the same.
  #
  # This inherits from the {Tree::BinaryTreeNode} class.
  #
  class BinaryMaxHeapNode < BinaryTreeNode
    include Tree::Utils::HeapSharedMethods

    # Inserts the specified node into the heap, based on the node content.
    #
    # @param [Tree::BinaryMaxHeapNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided. Must be comparable via +<=>+.
    #
    # @return [Tree::BinaryMaxHeapNode] The inserted node.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)
      tree_root = root

      if empty_root?(tree_root)
        validate_key!(node.content)
        tree_root.instance_variable_set(:@content, node.content)
        return tree_root
      end

      validate_key!(node.content)
      insert_at_index(tree_root, node)
      heapify_up(node)
      node
    end

    # Alias for {#insert} to keep consistency with Tree::TreeNode#add.
    #
    # This overrides Tree::TreeNode#add; the +at_index+ parameter is ignored
    # because heap nodes are inserted according to heap ordering and completeness.
    #
    # @param [Tree::BinaryMaxHeapNode] child The node to insert.
    # @return [Tree::BinaryMaxHeapNode] The inserted node.
    #
    # @see Tree::TreeNode#add
    def add(child, _at_index = -1)
      insert(child)
    end

    # Returns the root value without removing it.
    #
    # @return [Object, nil] The maximum heap value, or +nil+ if empty.
    def peek
      tree_root = root
      return nil if empty_root?(tree_root)

      tree_root.content
    end

    # Extracts and returns the maximum value from the heap.
    #
    # @return [Object, nil] The removed maximum value, or +nil+ if empty.
    def extract
      tree_root = root
      return nil if empty_root?(tree_root)

      removed = tree_root.content
      if heap_size(tree_root) == 1
        tree_root.instance_variable_set(:@content, nil)
        return removed
      end

      last = last_node(tree_root)
      tree_root.content = last.content
      remove_last_node(last)
      heapify_down(tree_root)
      removed
    end

    # Alias for {#extract} using priority-queue naming.
    #
    # @return [Object, nil] The removed maximum value, or +nil+ if empty.
    def pop
      extract
    end

    # Searches for a node matching the specified key (content).
    #
    # @param [Object] key The search key (node content).
    #
    # @return [Tree::BinaryMaxHeapNode, nil] The matching node, or +nil+.
    def search(key)
      validate_key!(key)
      tree_root = root
      return nil if empty_root?(tree_root)

      queue = [tree_root]
      index = 0
      while index < queue.length
        current = queue[index]
        index += 1
        next unless current

        direction = compare_keys(key, current.key)
        return current if direction.zero?
        next if direction.positive?

        queue << current.left_child
        queue << current.right_child
      end

      nil
    end

    # Deletes the node matching the specified key (content).
    #
    # @param [Object] key The key to delete.
    #
    # @return [Tree::BinaryMaxHeapNode, nil] The removed node, or +nil+ if not found.
    def delete(key)
      validate_key!(key)
      tree_root = root
      return nil if empty_root?(tree_root)

      node = search(key)
      return nil unless node

      removed = node.detached_copy
      remove_node(node)
      removed
    end

    # Returns the heap key for this node (the content).
    #
    # @return [Object] The node content used as the heap key.
    def key
      validate_key!(@content)
      @content
    end

    private

    # Coerce a name or node into a heap node instance.
    #
    # @param [Tree::BinaryMaxHeapNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Object] content The content (key) for the node, when a name is
    #   provided.
    # @return [Tree::BinaryMaxHeapNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::BinaryMaxHeapNode)
      if node_or_name.is_a?(Tree::TreeNode)
        raise ArgumentError, 'Binary max-heap nodes must be BinaryMaxHeapNode instances.'
      end

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two heap keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'Binary max-heap keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'Binary max-heap key (content) must not be nil.' if key.nil?
    end

    # Insert a node at the next available index to keep the heap complete.
    #
    # @param [Tree::BinaryMaxHeapNode] tree_root The root node.
    # @param [Tree::BinaryMaxHeapNode] node The node to insert.
    # @return [void]
    def insert_at_index(tree_root, node)
      index = heap_size(tree_root) + 1
      parent_index = index / 2
      parent = node_for_index(tree_root, parent_index)
      raise ArgumentError, 'Binary max-heap structure is incomplete.' unless parent

      if index.even?
        parent.left_child = node
      else
        parent.right_child = node
      end
    end

    # Restore heap ordering by bubbling the node upward.
    #
    # @param [Tree::BinaryMaxHeapNode] node The node to lift.
    # @return [void]
    def heapify_up(node)
      current = node
      while current.parent && compare_keys(current.key, current.parent.key).positive?
        swap_contents(current, current.parent)
        current = current.parent
      end
    end

    # Restore heap ordering by bubbling the node downward.
    #
    # @param [Tree::BinaryMaxHeapNode] node The node to sink.
    # @return [void]
    def heapify_down(node)
      current = node

      loop do
        left = current.left_child
        right = current.right_child
        break unless left || right

        swap_candidate = left || right
        swap_candidate = right if left && right && compare_keys(right.key, left.key).positive?

        break if compare_keys(current.key, swap_candidate.key) >= 0

        swap_contents(current, swap_candidate)
        current = swap_candidate
      end
    end

    # Rebalance heap ordering after swapping in a replacement node.
    #
    # @param [Tree::BinaryMaxHeapNode] node The node to rebalance from.
    # @return [void]
    def rebalance_after_swap(node)
      if node.parent && compare_keys(node.key, node.parent.key).positive?
        heapify_up(node)
      else
        heapify_down(node)
      end
    end
  end
end
