# traversal_methods.rb - This file is part of the RubyTree package.
#
# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
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
    # Provides traversal helpers for TreeNode.
    # rubocop:disable Metrics/ModuleLength
    module TreeTraversalHandler
      require 'stringio'
      # Traverses each node (including this node) of the (sub)tree rooted at this
      # node by yielding the nodes to the specified block.
      def each # :yields: node
        return to_enum unless block_given?

        node_stack = [self] # Start with this node

        until node_stack.empty?
          current = node_stack.pop # Pop the top-most node
          next unless current # Might be 'nil' (esp. for binary trees)

          yield current # and process it
          # Stack children of the current node at top of the stack
          current.send(:children_array).reverse_each do |child|
            node_stack << child if child
          end
        end

        self if block_given?
      end

      # Traverses the (sub)tree rooted at this node in pre-ordered sequence.
      def preordered_each(&) # :yields: node
        each(&)
      end

      # Traverses the (sub)tree rooted at this node in post-ordered sequence.
      def postordered_each
        return to_enum(:postordered_each) unless block_given?

        node_stack = [self] # Start with self
        visited = [false]

        until node_stack.empty?
          peek_node = node_stack[-1]
          if peek_node.children? && !visited[-1]
            visited[-1] = true
            peek_node.send(:children_array).reverse_each do |child|
              next unless child

              node_stack << child
              visited << false
            end
          else
            yield node_stack.pop
            visited.pop
          end
        end

        self if block_given?
      end

      # Performs breadth-first traversal of the (sub)tree rooted at this node.
      def breadth_each
        return to_enum(:breadth_each) unless block_given?

        node_queue = [self] # Create a queue with self as the initial entry
        queue_index = 0

        # Use a queue to do breadth traversal
        while queue_index < node_queue.length
          node_to_traverse = node_queue[queue_index]
          queue_index += 1
          next unless node_to_traverse

          yield node_to_traverse
          # Enqueue the children from left to right.
          node_to_traverse.send(:children_array).each do |child|
            node_queue << child if child
          end
        end

        self if block_given?
      end

      # Yields every leaf node of the (sub)tree rooted at this node.
      def each_leaf
        if block_given?
          each { |node| yield(node) if node.leaf? }
          self
        else
          self.select(&:leaf?)
        end
      end

      # Yields every level of the (sub)tree rooted at this node.
      def each_level
        if block_given?
          level = [self]
          until level.empty?
            yield level
            level = level.flat_map { |node| node.send(:children_array) }.filter_map { |child| child }
          end
          self
        else
          to_enum(:each_level)
        end
      end

      # Pretty prints the (sub)tree rooted at this node.
      # Output defaults to +$stdout+ unless an +io:+ is provided.
      def print_tree(level = node_depth, max_depth = nil,
                     block = nil, io: $stdout, &custom_block)
        block = resolve_print_block(block, custom_block, io)
        block.call(self, tree_prefix(level))

        # Exit if the max level is defined, and reached.
        return unless max_depth.nil? || level < max_depth

        # Child might be 'nil'
        children do |child|
          child&.print_tree(level + 1, max_depth, block, io: io)
        end
      end

      # Returns the pretty-printed tree output as a string.
      def print_tree_to_s(level = node_depth, max_depth = nil)
        buffer = StringIO.new
        print_tree(level, max_depth, io: buffer)
        buffer.string
      end

      def tree_prefix(level)
        prefix = ''.dup # dup must be invoked to make this mutable.

        if root?
          prefix << '*'
        else
          prefix << '|' unless parent.last_sibling?
          prefix << (' ' * (level - 1) * 4)
          prefix << (last_sibling? ? '+' : '|')
          prefix << '---'
          prefix << (children? ? '+' : '>')
        end

        prefix
      end

      def resolve_print_block(block, custom_block, io)
        return block if block
        return custom_block if custom_block

        lambda { |node, prefix|
          io.puts "#{prefix} #{node.name}"
        }
      end
      private :tree_prefix, :resolve_print_block
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
