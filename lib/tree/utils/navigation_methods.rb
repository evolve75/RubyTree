# navigation_methods.rb - This file is part of the RubyTree package.
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
    # Provides navigation helpers for TreeNode.
    module TreeNavigationHandler
      # +true+ if the this node has any child node.
      #
      # @note Nil child slots (e.g., in binary trees) do not count as children.
      def children?
        @children.any?
      end

      alias has_children? children? # @todo: Aliased for eventual replacement

      # An array of all the immediate children of this node.
      def children(&)
        if block_given?
          @children.each(&)
          self
        else
          @children.clone
        end
      end

      def children_array
        @children
      end

      # First child of this node.
      def first_child
        children_array.first
      end

      # Last child of this node.
      def last_child
        children_array.last
      end

      # First sibling of this node. If this is the root node, then returns itself.
      def first_sibling
        root? ? self : parent.send(:children_array).first
      end

      def first_sibling?
        first_sibling == self
      end

      alias is_first_sibling? first_sibling? # @todo: Aliased for eventual replacement

      # Last sibling of this node. If this is the root node, then returns itself.
      def last_sibling
        root? ? self : parent.send(:children_array).last
      end

      def last_sibling?
        last_sibling == self
      end

      alias is_last_sibling? last_sibling? # @todo: Aliased for eventual replacement

      # An array of siblings for this node. This node is excluded.
      #
      # @note Nil child slots (e.g., in binary trees) are skipped.
      def siblings(&block)
        return [] if root?

        siblings = []
        parent.send(:children_array).each do |sibling|
          next unless sibling
          next if sibling == self

          siblings << sibling
        end

        if block
          siblings.each(&block)
          self
        else
          siblings
        end
      end

      # +true+ if this node is the only child of its parent.
      def only_child?
        root? || parent.send(:children_array).one? { |child| child }
      end

      alias is_only_child? only_child? # @todo: Aliased for eventual replacement

      # Next sibling for this node.
      def next_sibling
        return nil if root?

        siblings = parent.send(:children_array)
        idx = siblings.index(self)
        siblings.at(idx + 1) if idx
      end

      # Previous sibling of this node.
      def previous_sibling
        return nil if root?

        siblings = parent.send(:children_array)
        idx = siblings.index(self)
        siblings.at(idx - 1) if idx&.positive?
      end

      private :children_array
    end
  end
end
