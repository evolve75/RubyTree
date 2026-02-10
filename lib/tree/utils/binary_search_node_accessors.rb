# binary_search_node_accessors.rb - This file is part of the RubyTree package.
#
# = binary_search_node_accessors.rb - Shared accessors for ordered binary nodes.
#
# Provides shared key/min/max helpers for ordered binary node types that use
# +content+ as the sortable key.
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
    # Shared key/min/max helpers for ordered binary node variants.
    module BinarySearchNodeAccessors
      # Returns the minimum node in the subtree rooted at this node.
      #
      # @return [Tree::BinaryTreeNode] The minimum node in the subtree.
      def min_node
        current = self
        current = current.left_child while current.left_child
        current
      end

      # Returns the maximum node in the subtree rooted at this node.
      #
      # @return [Tree::BinaryTreeNode] The maximum node in the subtree.
      def max_node
        current = self
        current = current.right_child while current.right_child
        current
      end

      # Returns the ordered key for this node (the content).
      #
      # @return [Object] The node content used as the key.
      def key
        validate_key!(@content)
        @content
      end
    end
  end
end
