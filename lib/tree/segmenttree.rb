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

require 'json'

module Tree
  # Provides a Segment Tree implementation for range sum queries.
  #
  # This structure supports:
  # - point updates
  # - range sum queries in O(log n)
  #
  # Unlike {Tree::TreeNode}, this class does not inherit from TreeNode and does
  # not expose parent/child navigation. It provides a TreeNode-like API subset
  # where it maps to segment tree semantics, including Enumerable iteration,
  # JSON/hash serialization, and comparison by ordered values.
  #
  # Iteration yields values in index order, not internal tree nodes.
  #
  # Indices are zero-based for public methods.
  #
  class SegmentTree
    include Enumerable
    include Comparable

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

    # Iterate over values in index order.
    #
    # @yieldparam value [Numeric] Value at each index.
    #
    # @return [Tree::SegmentTree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def each(&)
      return to_enum(:each) unless block_given?

      0.upto(@size - 1) { |index| yield self[index] }
      self
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

    # Set the value at the specified index.
    #
    # This is a convenience alias for {#update} to match array-style APIs.
    #
    # @param [Integer] index Zero-based index to update.
    # @param [Numeric] value The value to set.
    #
    # @return [Numeric] The stored value at the index.
    def []=(index, value)
      update(index, value)
      self[index]
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
    # @return [Hash] Hash representation of the segment tree.
    def to_h
      {
        size: size,
        values: to_a
      }
    end

    # Build a segment tree from a Hash representation.
    #
    # @param [Hash] hash Hash representation of a segment tree.
    # @return [Tree::SegmentTree] The constructed tree.
    def self.from_hash(hash)
      raise ArgumentError, 'Segment tree hash input must be a Hash.' unless hash.is_a?(Hash)

      size = if hash.key?(:size)
               hash[:size]
             else
               hash.fetch('size')
             end
      values = if hash.key?(:values)
                 hash[:values]
               elsif hash.key?('values')
                 hash['values']
               end
      new(size, values)
    end

    # JSON serialization for the segment tree.
    #
    # @param [Hash] _options JSON serialization options.
    # @return [Hash] Hash representation for JSON serialization.
    def as_json(_options = {})
      to_h
    end

    # Serialize the segment tree to JSON.
    #
    # @param [Array] args JSON.generate arguments.
    # @return [String] JSON representation of the tree.
    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    # Create a segment tree from a JSON hash.
    #
    # @param [Hash] json_hash JSON hash representation.
    # @return [Tree::SegmentTree] The constructed tree.
    def self.json_create(json_hash)
      from_hash(json_hash)
    end

    # Compare segment trees by their ordered values.
    #
    # @param [Tree::SegmentTree] other The segment tree to compare.
    # @return [Integer, nil] -1, 0, 1, or +nil+ if not comparable.
    def <=>(other)
      return nil unless other.is_a?(Tree::SegmentTree)

      to_a <=> other.to_a
    end

    private

    # Validate the size for the tree.
    #
    # @param [Integer] size The size to validate.
    # @raise [ArgumentError] If the size is invalid.
    def validate_size!(size)
      return if size.is_a?(Integer) && size.positive?

      raise ArgumentError, 'Segment tree size must be a positive integer.'
    end

    # Validate an index for access.
    #
    # @param [Integer] index The index to validate.
    # @raise [ArgumentError] If the index is out of range.
    def validate_index!(index)
      return if index.is_a?(Integer) && index.between?(0, @size - 1)

      raise ArgumentError, 'Segment tree index out of range.'
    end

    # Validate a value for updates.
    #
    # @param [Numeric] value The value to validate.
    # @raise [ArgumentError] If the value is nil.
    def validate_value!(value)
      raise ArgumentError, 'Segment tree value must not be nil.' if value.nil?
    end

    # Update a node in the segment tree.
    #
    # @param [Integer] node Internal node index.
    # @param [Integer] left Left bound for this node.
    # @param [Integer] right Right bound for this node.
    # @param [Integer] target Target index to update.
    # @param [Numeric] value Value to set.
    # @return [void]
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

    # Query the sum over a range in the segment tree.
    #
    # @param [Integer] node Internal node index.
    # @param [Integer] left Left bound for this node.
    # @param [Integer] right Right bound for this node.
    # @param [Integer] range_left Left bound of the query.
    # @param [Integer] range_right Right bound of the query.
    # @return [Numeric] Sum over the range.
    def query_sum(node, left, right, range_left, range_right)
      return @tree[node] if range_left <= left && right <= range_right
      return 0 if right < range_left || left > range_right

      mid = (left + right) / 2
      query_sum(node * 2, left, mid, range_left, range_right) +
        query_sum((node * 2) + 1, mid + 1, right, range_left, range_right)
    end
  end
end
