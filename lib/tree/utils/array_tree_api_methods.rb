# array_tree_api_methods.rb - This file is part of the RubyTree package.
#
# = array_tree_api_methods.rb - Shared API helpers for array-backed trees.
#
# Provides shared instance-level API methods for non-TreeNode, array-backed
# tree implementations.
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
    # Shared instance-level API methods for array-backed tree types.
    module ArrayTreeApiMethods
      # Convenience synonym for +size+.
      #
      # @return [Integer] The number of elements tracked by the tree.
      def length
        size
      end

      # Iterate over values in index order.
      #
      # @yieldparam value [Numeric] Value at each index.
      #
      # @return [Object] The receiver, if a block is given.
      # @return [Enumerator] An enumerator, if no block is given.
      def each(&)
        return to_enum(:each) unless block_given?

        0.upto(@size - 1) { |index| yield self[index] }
        self
      end

      # Returns all values in index order.
      #
      # @return [Array<Numeric>] Values in index order.
      def values
        to_a
      end

      # Returns all indices in order.
      #
      # @return [Array<Integer>] Indices in order.
      def keys
        (0...@size).to_a
      end

      # Returns all values as an Array.
      #
      # @return [Array<Numeric>] Values in index order.
      def to_a
        map { |value| value }
      end

      # Returns a Hash representation of the tree.
      #
      # @return [Hash] Hash representation of the tree.
      def to_h
        {
          size: size,
          values: to_a
        }
      end

      # JSON serialization for the tree.
      #
      # @param [Hash] _options JSON serialization options.
      # @return [Hash] Hash representation for JSON serialization.
      def as_json(_options = {})
        to_h
      end

      # Serialize the tree to JSON.
      #
      # @param [Array] args JSON.generate arguments.
      # @return [String] JSON representation of the tree.
      def to_json(*args)
        JSON.generate(as_json, *args)
      end

      # Compare trees by their ordered values.
      #
      # @param [Object] other The tree to compare.
      # @return [Integer, nil] -1, 0, 1, or +nil+ if not comparable.
      def <=>(other)
        return nil unless other.is_a?(self.class)

        to_a <=> other.to_a
      end
    end
  end
end
