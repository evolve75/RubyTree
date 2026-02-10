# fenwicktree.rb - This file is part of the RubyTree package.
#
# = fenwicktree.rb - An implementation of the Fenwick (binary indexed) tree.
#
# Provides a Fenwick tree for efficient prefix and range sum queries with
# point updates.
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
require_relative 'utils/array_tree_api_methods'

module Tree
  # Provides a Fenwick (binary indexed) tree implementation.
  #
  # This structure supports:
  # - point updates (additive)
  # - prefix sums in O(log n)
  # - range sums in O(log n)
  #
  # Unlike {Tree::TreeNode}, this class does not inherit from TreeNode and does
  # not expose parent/child navigation. It provides a TreeNode-like API subset
  # where it maps to Fenwick tree semantics, including Enumerable iteration,
  # JSON/hash serialization, and comparison by ordered values.
  #
  # Iteration yields values in index order, not internal tree nodes.
  #
  # Indices are zero-based for public methods.
  #
  # @note The +<<+ operator is intentionally not supported for this class.
  #   Fenwick trees require explicit indexed updates via {#update} or {#[]=},
  #   and do not model append-style insertion semantics.
  #
  class FenwickTree
    include Enumerable
    include Comparable
    include Tree::Utils::ArrayTreeApiMethods

    # @!attribute [r] size
    # Size of the tree (number of elements).
    #
    # @return [Integer] The number of elements tracked by the tree.
    attr_reader :size

    # Create a Fenwick tree of the specified size.
    #
    # @param [Integer] size The number of elements to track.
    # @param [Array, nil] values Optional initial values (zero-based).
    #
    # @raise [ArgumentError] If size is not a positive integer.
    # @raise [ArgumentError] If values length exceeds size.
    def initialize(size, values = nil)
      validate_size!(size)
      @size = size
      @tree = Array.new(@size + 1, 0)

      return unless values
      raise ArgumentError, 'Initial values exceed Fenwick tree size.' if values.length > @size

      values.each_with_index do |value, index|
        next if value.nil?

        update(index, value)
      end
    end

    # Add a delta to the value at the specified index.
    #
    # @param [Integer] index Zero-based index to update.
    # @param [Numeric] delta The value to add.
    #
    # @return [void]
    #
    # @raise [ArgumentError] If index is out of range.
    # @raise [ArgumentError] If delta is +nil+.
    def update(index, delta)
      validate_index!(index)
      validate_delta!(delta)

      idx = index + 1
      while idx <= @size
        @tree[idx] += delta
        idx += idx & -idx
      end
    end

    # Prefix sum from index 0 up to the specified index (inclusive).
    #
    # @param [Integer] index Zero-based index.
    #
    # @return [Numeric] Prefix sum value.
    #
    # @raise [ArgumentError] If index is out of range.
    def sum(index)
      return 0 if index.negative?

      validate_index!(index)

      idx = index + 1
      total = 0
      while idx.positive?
        total += @tree[idx]
        idx -= idx & -idx
      end
      total
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

      sum(right) - sum(left - 1)
    end

    # Alias for {#range_sum} with query-oriented naming.
    #
    # @param [Integer] left The starting index.
    # @param [Integer] right The ending index.
    # @return [Numeric] Sum in the specified range.
    def query(left, right)
      range_sum(left, right)
    end

    # Read the value at the specified index.
    #
    # @param [Integer] index Zero-based index.
    #
    # @return [Numeric] Value at index.
    def [](index)
      range_sum(index, index)
    end

    # Add a delta to the value at the specified index.
    #
    # This is a convenience alias for {#update} to match array-style APIs.
    #
    # @param [Integer] index Zero-based index to update.
    # @param [Numeric] delta The value to add.
    #
    # @return [Numeric] The updated value at the index.
    def []=(index, delta)
      update(index, delta)
      self[index]
    end

    # Build a Fenwick tree from a Hash representation.
    #
    # @param [Hash] hash Hash representation of a Fenwick tree.
    # @return [Tree::FenwickTree] The constructed tree.
    def self.from_hash(hash)
      raise ArgumentError, 'Fenwick tree hash input must be a Hash.' unless hash.is_a?(Hash)

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

    # Create a Fenwick tree from a JSON hash.
    #
    # @param [Hash] json_hash JSON hash representation.
    # @return [Tree::FenwickTree] The constructed tree.
    def self.json_create(json_hash)
      from_hash(json_hash)
    end

    private

    # Validate the size for the tree.
    #
    # @param [Integer] size The size to validate.
    # @raise [ArgumentError] If the size is invalid.
    def validate_size!(size)
      return if size.is_a?(Integer) && size.positive?

      raise ArgumentError, 'Fenwick tree size must be a positive integer.'
    end

    # Validate an index for access.
    #
    # @param [Integer] index The index to validate.
    # @raise [ArgumentError] If the index is out of range.
    def validate_index!(index)
      return if index.is_a?(Integer) && index.between?(0, @size - 1)

      raise ArgumentError, 'Fenwick tree index out of range.'
    end

    # Validate a delta for updates.
    #
    # @param [Numeric] delta The delta to validate.
    # @raise [ArgumentError] If the delta is nil.
    def validate_delta!(delta)
      raise ArgumentError, 'Update delta must not be nil.' if delta.nil?
    end
  end
end
