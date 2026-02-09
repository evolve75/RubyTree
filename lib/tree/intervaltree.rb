# intervaltree.rb - This file is part of the RubyTree package.
#
# = intervaltree.rb - An implementation of the interval tree data structure.
#
# Provides an interval tree (augmented red-black tree) for efficient overlap
# queries on intervals.
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

require_relative 'redblacktree'

module Tree
  # Provides an Interval Tree implementation. This node allows only two child
  # nodes (left and right child), and maintains BST ordering on the interval
  # start. Each node stores the maximum interval end in its subtree to allow
  # efficient overlap searches.
  #
  # Interval content can be provided as a Ruby Range (+start..finish+) or a
  # two-element array (+[start, finish]+).
  #
  # @note Interval endpoints must be comparable using +<=>+ and satisfy
  #   +start <= finish+.
  #
  # @note Insert/delete operations can change the root via rotations. If you
  #   retain an older root reference, use +node.root+ to retrieve the current
  #   root after modifications.
  #
  class IntervalTreeNode < RedBlackTreeNode
    # @!attribute [r] max_end
    # Maximum interval end in the subtree rooted at this node.
    attr_reader :max_end

    # Create an interval tree node.
    #
    # @param [String, Symbol] name Name of the node.
    # @param [Range, Array] content Interval stored in this node.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    def initialize(name, content = nil, options = nil)
      super
      @max_end = content ? interval_bounds(content)[1] : nil
    end

    # Inserts the specified node into the interval tree.
    #
    # @param [Tree::IntervalTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Range, Array] content The interval content when a name is provided.
    #
    # @return [Tree::IntervalTreeNode] The inserted node.
    #
    # @raise [ArgumentError] If the interval is invalid or not comparable.
    def insert(node_or_name, content = nil)
      node = coerce_node(node_or_name, content)

      if root? && @content.nil?
        validate_interval!(node.content)
        @content = node.content
        @max_end = interval_bounds(@content)[1]
        @color = :black
        return self
      end

      validate_interval!(node.content)
      node.color = :red
      inserted = bst_insert(node)
      fix_insert(inserted)
      root.color = :black if root&.content
      refresh_max_end!
      inserted
    end

    # Alias for {#insert} to keep consistency with {Tree::TreeNode#add}.
    #
    # @param [Tree::IntervalTreeNode] child The node to insert.
    # @return [Tree::IntervalTreeNode] The inserted node.
    def add(child, _at_index = -1)
      insert(child)
    end

    # Searches for a node matching the specified interval or interval start.
    #
    # @param [Range, Array, Object] key_or_interval The interval or start key.
    #
    # @return [Tree::IntervalTreeNode, nil] The matching node, or +nil+.
    def search(key_or_interval)
      return search_interval(key_or_interval) if interval_input?(key_or_interval)

      search_start(key_or_interval)
    end

    # Deletes the node matching the specified interval or interval start.
    #
    # @param [Range, Array, Object] key_or_interval The interval or start key.
    #
    # @return [Tree::IntervalTreeNode, nil] The removed node, or +nil+ if not found.
    def delete(key_or_interval)
      node = search(key_or_interval)
      return nil unless node

      removed = node.detached_copy
      node.send(:delete_node!)
      root.color = :black if root&.content
      refresh_max_end!
      removed
    end

    # Returns the interval key for this node (start/end).
    #
    # @return [Array] Interval key in the form +[start, end]+.
    def key
      bounds = interval_bounds(@content)
      [bounds[0], bounds[1]]
    end

    # Returns the interval start for this node.
    #
    # @return [Object] Interval start value.
    def interval_start
      interval_bounds(@content)[0]
    end

    # Returns the interval end for this node.
    #
    # @return [Object] Interval end value.
    def interval_end
      interval_bounds(@content)[1]
    end

    # Returns nodes whose intervals overlap the specified interval.
    #
    # @param [Range, Array] interval The interval to query.
    #
    # @return [Array<Tree::IntervalTreeNode>] Nodes with overlapping intervals.
    def search_overlaps(interval)
      results = []
      bounds = interval_bounds(interval)
      search_overlaps_in_subtree(self, bounds, results)
      results
    end

    # Returns nodes whose intervals overlap the specified point.
    #
    # @param [Object] point The point to query.
    #
    # @return [Array<Tree::IntervalTreeNode>] Nodes with overlapping intervals.
    def search_point(point)
      search_overlaps([point, point])
    end

    # Recompute max_end for the subtree rooted at this node.
    #
    # @return [Tree::IntervalTreeNode] The receiver.
    def refresh_max_end!
      postordered_each { |node| node.send(:recompute_max_end!) }
      self
    end

    private

    # Coerce a name or node into an interval tree node instance.
    #
    # @param [Tree::IntervalTreeNode, String, Symbol] node_or_name The node
    #   instance to insert, or the node name to create.
    # @param [Range, Array] content The interval content.
    # @return [Tree::IntervalTreeNode] A node instance.
    def coerce_node(node_or_name, content)
      return node_or_name if node_or_name.is_a?(Tree::IntervalTreeNode)
      raise ArgumentError, 'Interval nodes must be IntervalTreeNode instances.' if node_or_name.is_a?(Tree::TreeNode)

      self.class.new(node_or_name, content, { checks: checks_enabled? })
    end

    # Compare two interval keys.
    #
    # @param [Array] left The left interval key.
    # @param [Array] right The right interval key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'Interval keys must be comparable using <=>.' if result.nil?

      result
    end

    # Search for a node matching the specified interval.
    #
    # @param [Range, Array] interval The interval to find.
    # @return [Tree::IntervalTreeNode, nil] The matching node, or +nil+.
    def search_interval(interval)
      validate_interval!(interval)
      target_key = interval_key(interval)
      current = self
      while current
        direction = compare_keys(target_key, current.key)
        return current if direction.zero?

        current = direction.negative? ? current.left_child : current.right_child
      end
      nil
    end

    # Search for a node matching the specified interval start.
    #
    # @param [Object] start The interval start to find.
    # @return [Tree::IntervalTreeNode, nil] The matching node, or +nil+.
    def search_start(start)
      validate_start!(start)
      current = self
      while current
        direction = compare_values(start, current.interval_start)
        return current if direction.zero?

        current = direction.negative? ? current.left_child : current.right_child
      end
      nil
    end

    # Check whether a value is a valid interval input.
    #
    # @param [Object] value The value to check.
    # @return [Boolean] +true+ if the value is an interval input.
    def interval_input?(value)
      value.is_a?(Range) || (value.is_a?(Array) && value.length == 2)
    end

    # Return interval bounds [start, end, exclude_end].
    #
    # @param [Range, Array] interval The interval to normalize.
    # @return [Array] Normalized bounds.
    def interval_bounds(interval)
      raise ArgumentError, 'Interval must be a Range or two-element Array.' unless interval_input?(interval)

      start, finish, exclude_end =
        if interval.is_a?(Range)
          [interval.begin, interval.end, interval.exclude_end?]
        else
          [interval[0], interval[1], false]
        end

      validate_bounds!(start, finish)
      [start, finish, exclude_end]
    end

    # Validate an interval input.
    #
    # @param [Range, Array] interval The interval to validate.
    # @return [void]
    def validate_interval!(interval)
      interval_bounds(interval)
      nil
    end

    # Validate that a start key is comparable.
    #
    # @param [Object] start The start value to validate.
    # @return [void]
    def validate_start!(start)
      raise ArgumentError, 'Interval start must not be nil.' if start.nil?

      compare_values(start, start)
    end

    # Validate bounds and ordering.
    #
    # @param [Object] start Interval start.
    # @param [Object] finish Interval end.
    # @return [void]
    def validate_bounds!(start, finish)
      raise ArgumentError, 'Interval start/end must not be nil.' if start.nil? || finish.nil?

      cmp = compare_values(start, finish)
      raise ArgumentError, 'Interval start must be <= end.' if cmp.positive?
    end

    # Return the interval key for an interval.
    #
    # @param [Range, Array] interval The interval to normalize.
    # @return [Array] Interval key in the form +[start, end]+.
    def interval_key(interval)
      bounds = interval_bounds(interval)
      [bounds[0], bounds[1]]
    end

    # Compare two values using +<=>+.
    #
    # @param [Object] left The left value.
    # @param [Object] right The right value.
    # @return [Integer] -1, 0, or 1.
    def compare_values(left, right)
      result = left <=> right
      raise ArgumentError, 'Interval endpoints must be comparable using <=>.' if result.nil?

      result
    end

    # Recompute max_end for this node.
    #
    # @return [void]
    def recompute_max_end!
      value = @content ? interval_bounds(@content)[1] : nil
      left_max = left_child&.max_end
      right_max = right_child&.max_end
      @max_end = max_value(value, left_max, right_max)
    end

    # Return the maximum non-nil value.
    #
    # @param [Array<Object>] values Candidate values.
    # @return [Object, nil] Maximum value, or +nil+ if all values are +nil+.
    def max_value(*values)
      values.compact.max { |a, b| compare_values(a, b) }
    end

    # Determine if two intervals overlap.
    #
    # @param [Array] left_bounds Left interval bounds.
    # @param [Array] right_bounds Right interval bounds.
    # @return [Boolean] +true+ if the intervals overlap.
    def intervals_overlap?(left_bounds, right_bounds)
      return false if interval_before?(left_bounds, right_bounds)
      return false if interval_before?(right_bounds, left_bounds)

      true
    end

    # Search for overlaps in a subtree.
    #
    # @param [Tree::IntervalTreeNode, nil] node Subtree root.
    # @param [Array] target_bounds Target interval bounds.
    # @param [Array<Tree::IntervalTreeNode>] results Accumulator.
    # @return [void]
    def search_overlaps_in_subtree(node, target_bounds, results)
      return unless node&.content

      results << node if intervals_overlap?(interval_bounds(node.content), target_bounds)

      search_overlaps_in_subtree(node.left_child, target_bounds, results) if should_search_left?(node, target_bounds[0])

      target_end = target_bounds[1]
      target_excl = target_bounds[2]
      return unless should_search_right?(node, target_end, target_excl)

      search_overlaps_in_subtree(node.right_child, target_bounds, results)
    end

    # Determine if the left subtree could contain overlaps.
    #
    # @param [Tree::IntervalTreeNode] node Current node.
    # @param [Object] target_start Target interval start.
    # @return [Boolean] +true+ if the left subtree should be searched.
    def should_search_left?(node, target_start)
      left = node.left_child
      return false unless left&.max_end

      compare = compare_values(left.max_end, target_start)
      compare.positive? || compare.zero?
    end

    # Determine if the right subtree could contain overlaps.
    #
    # @param [Tree::IntervalTreeNode] node Current node.
    # @param [Object] target_end Target interval end.
    # @param [Boolean] target_excl Whether the target end is exclusive.
    # @return [Boolean] +true+ if the right subtree should be searched.
    def should_search_right?(node, target_end, target_excl)
      return false unless node.right_child

      compare = compare_values(target_end, node.interval_start)
      return true if compare.positive?
      return !target_excl if compare.zero?

      false
    end

    # Determine if one interval is entirely before another.
    #
    # @param [Array] left_bounds Left interval bounds.
    # @param [Array] right_bounds Right interval bounds.
    # @return [Boolean] +true+ if the left interval ends before the right starts.
    def interval_before?(left_bounds, right_bounds)
      left_end = left_bounds[1]
      left_excl = left_bounds[2]
      right_start = right_bounds[0]

      comparison = compare_values(left_end, right_start)
      return true if comparison.negative?
      return true if comparison.zero? && left_excl

      false
    end
  end
end
