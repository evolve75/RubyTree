# heap_shared_methods.rb - This file is part of the RubyTree package.
#
# = heap_shared_methods.rb - Shared helpers for binary heap node types.
#
# Provides shared internal helpers used by both min-heap and max-heap node
# implementations.
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

module Tree
  module Utils
    # Shared helper methods for heap node internals.
    module HeapSharedMethods
      private

      # +true+ if the root represents an empty heap.
      #
      # @param [Tree::BinaryTreeNode] node The node to check.
      # @return [Boolean] +true+ if empty.
      def empty_root?(node)
        node.root? && node.content.nil? && !node.children?
      end

      # Returns the heap size treating an empty root as size 0.
      #
      # @param [Tree::BinaryTreeNode] node The root node.
      # @return [Integer] The heap size.
      def heap_size(node)
        return 0 if empty_root?(node)

        node.size
      end

      # Return the node at the given heap index.
      #
      # @param [Tree::BinaryTreeNode] tree_root The root node.
      # @param [Integer] index The heap index (1-based).
      # @return [Tree::BinaryTreeNode, nil] The node at the index.
      def node_for_index(tree_root, index)
        return tree_root if index == 1

        current = tree_root
        path_bits = index.to_s(2).chars.drop(1)
        path_bits.each do |bit|
          current = bit == '0' ? current.left_child : current.right_child
          return nil unless current
        end
        current
      end

      # Return the last node in the heap (right-most node at the deepest level).
      #
      # @param [Tree::BinaryTreeNode] tree_root The root node.
      # @return [Tree::BinaryTreeNode] The last node.
      def last_node(tree_root)
        node_for_index(tree_root, heap_size(tree_root))
      end

      # Swap the content values of two nodes.
      #
      # @param [Tree::BinaryTreeNode] left The first node.
      # @param [Tree::BinaryTreeNode] right The second node.
      # @return [void]
      def swap_contents(left, right)
        left.content, right.content = right.content, left.content
      end

      # Remove the last node from the heap.
      #
      # @param [Tree::BinaryTreeNode] node The last node.
      # @return [void]
      def remove_last_node(node)
        if node.root?
          node.instance_variable_set(:@content, nil)
          return
        end

        if node.left_child?
          node.parent.left_child = nil
        else
          node.parent.right_child = nil
        end
      end

      # Remove an arbitrary node from the heap.
      #
      # @param [Tree::BinaryTreeNode] node The node to remove.
      # @return [void]
      def remove_node(node)
        tree_root = root
        return if empty_root?(tree_root)

        if heap_size(tree_root) == 1
          tree_root.instance_variable_set(:@content, nil)
          return
        end

        last = last_node(tree_root)
        if node.equal?(last)
          remove_last_node(last)
          return
        end

        swap_contents(node, last)
        remove_last_node(last)
        rebalance_after_swap(node)
      end
    end
  end
end
