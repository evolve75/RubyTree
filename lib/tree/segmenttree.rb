# segmenttree.rb - This file is part of the RubyTree package.
#
# = segmenttree.rb - An implementation of the segment tree data structure.
#
# Provides a segment tree for range sum queries with point updates.
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
  # Provides a Segment Tree implementation for range sum queries.
  #
  # This structure supports:
  # - point updates
  # - range sum queries in O(log n)
  #
  # Indices are zero-based for public methods.
  #
  class SegmentTree
    # @!attribute [r] size
    # Size of the tree (number of elements).
    #
    # @return [Integer] The number of elements tracked by the tree.
    attr_reader :size

    # Create a segment tree of the specified size.
    #
    # @param [Integer] size The number of elements to track.
    # @param [Array, nil] values Optional initial values (zero-based).
    #
    # @raise [ArgumentError] If size is not a positive integer.
    # @raise [ArgumentError] If values length exceeds size.
    def initialize(size, values = nil)
      validate_size!(size)
      @size = size
      @tree = Array.new(@size * 4, 0)

      return unless values
      raise ArgumentError, 'Initial values exceed segment tree size.' if values.length > @size

      values.each_with_index do |value, index|
        next if value.nil?

        update(index, value)
      end
    end

    # Convenience synonym for {#size}.
    #
    # @return [Integer] The number of elements tracked by the tree.
    def length
      size
    end

    # Set the value at the specified index.
    #
    # @param [Integer] index Zero-based index to update.
    # @param [Numeric] value The value to set.
    #
    # @return [void]
    #
    # @raise [ArgumentError] If index is out of range.
    # @raise [ArgumentError] If value is +nil+.
    def update(index, value)
      validate_index!(index)
      validate_value!(value)

      update_node(1, 0, @size - 1, index, value)
    end

    # Range sum from +left+ to +right+ indices (inclusive).
    #
    # @param [Integer] left The starting index.
    # @param [Integer] right The ending index.
    #
    # @return [Numeric] Sum in the specified range.
    #
    # @raise [ArgumentError] If indices are out of range or left > right.
    def range_sum(left, right)
      validate_index!(left)
      validate_index!(right)
      raise ArgumentError, 'Range start must be <= range end.' if left > right

      query_sum(1, 0, @size - 1, left, right)
    end

    # Read the value at the specified index.
    #
    # @param [Integer] index Zero-based index.
    #
    # @return [Numeric] Value at index.
    def [](index)
      range_sum(index, index)
    end

    private

    def validate_size!(size)
      return if size.is_a?(Integer) && size.positive?

      raise ArgumentError, 'Segment tree size must be a positive integer.'
    end

    def validate_index!(index)
      return if index.is_a?(Integer) && index.between?(0, @size - 1)

      raise ArgumentError, 'Segment tree index out of range.'
    end

    def validate_value!(value)
      raise ArgumentError, 'Segment tree value must not be nil.' if value.nil?
    end

    def update_node(node, left, right, target, value)
      if left == right
        @tree[node] = value
        return
      end

      mid = (left + right) / 2
      if target <= mid
        update_node(node * 2, left, mid, target, value)
      else
        update_node((node * 2) + 1, mid + 1, right, target, value)
      end

      @tree[node] = @tree[node * 2] + @tree[(node * 2) + 1]
    end

    def query_sum(node, left, right, range_left, range_right)
      return @tree[node] if range_left <= left && right <= range_right
      return 0 if right < range_left || left > range_right

      mid = (left + right) / 2
      query_sum(node * 2, left, mid, range_left, range_right) +
        query_sum((node * 2) + 1, mid + 1, right, range_left, range_right)
    end
  end
end
