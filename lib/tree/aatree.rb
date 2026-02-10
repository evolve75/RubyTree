# aatree.rb - This file is part of the RubyTree package.
#
# = aatree.rb - An implementation of the AA tree data structure.
#
# Provides an AA tree data structure with ordered insert/search/delete
# operations based on node keys.
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
  # Provides an AA Tree implementation for ordered insert/search/delete.
  #
  # This implementation stores key/value pairs and maintains AA-tree invariants
  # using skew and split rotations. It does not inherit from {Tree::TreeNode}.
  # Instead, it provides a TreeNode-like API subset (Enumerable traversal,
  # Comparable, and JSON/hash serialization) aligned with AA-tree semantics.
  #
  class AATree
    include Enumerable
    include Comparable

    # Key/value entry for the AA tree.
    Entry = Struct.new(:key, :value)

    # Internal node representation for the AA tree.
    Node = Struct.new(:entry, :level, :left, :right)

    # Create an AA tree.
    #
    # @param [Array, nil] entries Optional initial entries.
    def initialize(entries = nil)
      @root = nil
      return unless entries

      entries.each do |entry|
        if entry.is_a?(Array)
          insert(entry[0], entry[1])
        else
          insert(entry[:key], entry[:value])
        end
      end
    end

    # Insert a key/value pair into the AA tree.
    #
    # @param [Object] key The key to insert. Must be comparable via +<=>+.
    # @param [Object] value The value associated with the key.
    # @return [Tree::AATree::Entry] The inserted entry.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(key, value = nil)
      validate_key!(key)
      entry = Entry.new(key, value)
      @root, inserted = insert_node(@root, entry)
      inserted
    end

    # Insert an entry using natural +<<+ syntax.
    #
    # @param [Array, Hash, Tree::AATree::Entry] entry Input entry as
    #   +[key, value]+, +{ key:, value: }+, or {Tree::AATree::Entry}.
    # @return [Tree::AATree::Entry] The inserted entry.
    #
    # @raise [ArgumentError] If the input format is unsupported.
    def <<(entry)
      key, value = entry_to_pair(entry)
      insert(key, value)
    end

    # Search for a key in the AA tree.
    #
    # @param [Object] key The key to search for.
    # @return [Object, nil] The matching value, or +nil+.
    def search(key)
      validate_key!(key)
      current = @root
      while current
        direction = compare_keys(key, current.entry.key)
        return current.entry.value if direction.zero?

        current = direction.negative? ? current.left : current.right
      end
      nil
    end

    # Alias for {#search} to support lookup-oriented naming.
    #
    # @param [Object] key The key to search for.
    # @return [Object, nil] The matching value, or +nil+.
    def lookup(key)
      search(key)
    end

    # Delete a key from the AA tree.
    #
    # @param [Object] key The key to delete.
    # @return [Object, nil] The removed value, or +nil+ if not found.
    def delete(key)
      validate_key!(key)
      @root, removed = delete_node(@root, key)
      removed&.value
    end

    # Return the number of entries stored in the AA tree.
    #
    # @return [Integer] The number of entries in the tree.
    def size
      count_entries(@root)
    end

    # Convenience synonym for {#size}.
    #
    # @return [Integer] The number of entries in the tree.
    def length
      size
    end

    # Iterate over entries in sorted key order.
    #
    # @yieldparam entry [Tree::AATree::Entry] Each entry in order.
    # @return [Tree::AATree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def each(&)
      return to_enum(:each) unless block_given?

      inorder_entries(@root, &)
      self
    end

    # Pre-order traversal over entries.
    #
    # @yieldparam entry [Tree::AATree::Entry] Each entry in pre-order.
    # @return [Tree::AATree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def preordered_each(&)
      return to_enum(:preordered_each) unless block_given?

      preorder_entries(@root, &)
      self
    end

    # Post-order traversal over entries.
    #
    # @yieldparam entry [Tree::AATree::Entry] Each entry in post-order.
    # @return [Tree::AATree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def postordered_each(&)
      return to_enum(:postordered_each) unless block_given?

      postorder_entries(@root, &)
      self
    end

    # Breadth-first traversal over entries.
    #
    # @yieldparam entry [Tree::AATree::Entry] Each entry in breadth-first order.
    # @return [Tree::AATree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def breadth_each(&)
      return to_enum(:breadth_each) unless block_given?

      breadth_entries(@root, &)
      self
    end

    # Read the value for the specified key.
    #
    # @param [Object] key The key to read.
    # @return [Object, nil] The stored value.
    def [](key)
      search(key)
    end

    # Set the value for the specified key.
    #
    # @param [Object] key The key to set.
    # @param [Object] value The value to associate with the key.
    # @return [Object] The value.
    def []=(key, value)
      insert(key, value).value
    end

    # Returns all keys in sorted order.
    #
    # @return [Array<Object>] Keys in sorted order.
    def keys
      map(&:key)
    end

    # Returns all values in key order.
    #
    # @return [Array<Object>] Values in sorted order by key.
    def values
      map(&:value)
    end

    # Returns all entries as `[key, value]` pairs.
    #
    # @return [Array<Array>] Array of `[key, value]` pairs.
    def to_a
      map { |entry| [entry.key, entry.value] }
    end

    # Returns a Hash representation of the tree.
    #
    # @return [Hash] Hash representation of the AA tree.
    def to_h
      {
        root: node_to_h(@root)
      }
    end

    # Build an AA tree from a Hash representation.
    #
    # @param [Hash] hash Hash representation of an AA tree.
    # @return [Tree::AATree] The constructed tree.
    def self.from_hash(hash)
      raise ArgumentError, 'AA tree hash input must be a Hash.' unless hash.is_a?(Hash)

      tree = new
      root_hash = hash.fetch(:root, hash.fetch('root', nil))
      tree.instance_variable_set(:@root, tree.send(:node_from_h, root_hash)) if root_hash
      tree
    end

    # JSON serialization for the AA tree.
    #
    # @param [Hash] _options JSON serialization options.
    # @return [Hash] Hash representation for JSON serialization.
    def as_json(_options = {})
      to_h
    end

    # Serialize the AA tree to JSON.
    #
    # @param [Array] args JSON.generate arguments.
    # @return [String] JSON representation of the tree.
    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    # Create an AA tree from a JSON hash.
    #
    # @param [Hash] json_hash JSON hash representation.
    # @return [Tree::AATree] The constructed tree.
    def self.json_create(json_hash)
      from_hash(json_hash)
    end

    # Compare AA trees by their in-order key/value pairs.
    #
    # @param [Tree::AATree] other The AA tree to compare.
    # @return [Integer, nil] -1, 0, 1, or +nil+ if not comparable.
    def <=>(other)
      return nil unless other.is_a?(Tree::AATree)

      to_a <=> other.to_a
    end

    private

    # Convert a supported entry input into a key/value pair.
    #
    # @param [Array, Hash, Tree::AATree::Entry] entry Input entry.
    # @return [Array<Object, Object>] The +[key, value]+ pair.
    #
    # @raise [ArgumentError] If the input format is unsupported.
    def entry_to_pair(entry)
      return [entry.key, entry.value] if entry.is_a?(Entry)
      return array_entry_to_pair(entry) if entry.is_a?(Array)
      return hash_entry_to_pair(entry) if entry.is_a?(Hash)

      raise ArgumentError, 'AA tree << expects [key, value], { key:, value: }, or Entry.'
    end

    # Convert an array entry into a key/value pair.
    #
    # @param [Array] entry Input as +[key, value]+.
    # @return [Array<Object, Object>] The +[key, value]+ pair.
    #
    # @raise [ArgumentError] If the array shape is invalid.
    def array_entry_to_pair(entry)
      raise ArgumentError, 'AA tree << expects [key, value].' unless entry.length == 2

      [entry[0], entry[1]]
    end

    # Convert a hash entry into a key/value pair.
    #
    # @param [Hash] entry Input as +{ key:, value: }+.
    # @return [Array<Object, Object>] The +[key, value]+ pair.
    #
    # @raise [ArgumentError] If the hash shape is invalid.
    def hash_entry_to_pair(entry)
      has_symbol_key = entry.key?(:key)
      has_string_key = entry.key?('key')
      raise ArgumentError, 'AA tree << expects { key:, value: }.' unless has_symbol_key || has_string_key

      key = has_symbol_key ? entry[:key] : entry['key']
      value = entry.key?(:value) ? entry[:value] : entry['value']
      [key, value]
    end

    # Insert an entry into a node and return the new subtree root.
    #
    # @param [Tree::AATree::Node, nil] node The current subtree root.
    # @param [Tree::AATree::Entry] entry Entry to insert.
    # @return [Array(Tree::AATree::Node, Tree::AATree::Entry)] The new root and inserted entry.
    def insert_node(node, entry)
      return [Node.new(entry, 1, nil, nil), entry] unless node

      direction = compare_keys(entry.key, node.entry.key)

      if direction.negative?
        node.left, inserted = insert_node(node.left, entry)
      elsif direction.positive?
        node.right, inserted = insert_node(node.right, entry)
      else
        node.entry.value = entry.value
        return [node, node.entry]
      end

      node = skew(node)
      node = split(node)
      [node, inserted]
    end

    # Delete an entry from a subtree.
    #
    # @param [Tree::AATree::Node, nil] node The current subtree root.
    # @param [Object] key The key to delete.
    # @return [Array(Tree::AATree::Node, Tree::AATree::Entry)] The new root and removed entry.
    def delete_node(node, key)
      return [nil, nil] unless node

      node, removed = delete_from_subtree(node, key)
      return [node, removed] unless node

      [rebalance_after_delete(node), removed]
    end

    # Delete a key from a subtree without rebalancing.
    #
    # @param [Tree::AATree::Node] node The current subtree root.
    # @param [Object] key The key to delete.
    # @return [Array(Tree::AATree::Node, Tree::AATree::Entry)] The updated node and removed entry.
    def delete_from_subtree(node, key)
      comparison = compare_keys(key, node.entry.key)

      if comparison.negative?
        node.left, removed = delete_node(node.left, key)
        return [node, removed]
      end

      if comparison.positive?
        node.right, removed = delete_node(node.right, key)
        return [node, removed]
      end

      removed = node.entry
      return [node.left || node.right, removed] unless node.left && node.right

      successor = min_node(node.right)
      node.entry = successor.entry
      node.right, _removed = delete_node(node.right, successor.entry.key)
      [node, removed]
    end

    # Rebalance a subtree after deletion.
    #
    # @param [Tree::AATree::Node] node The subtree root.
    # @return [Tree::AATree::Node] The rebalanced subtree root.
    def rebalance_after_delete(node)
      node = decrease_level(node)
      node = skew(node)
      node.right = skew(node.right) if node.right
      node.right.right = skew(node.right.right) if node.right&.right
      node = split(node)
      node.right = split(node.right) if node.right

      node
    end

    # Rotate a node right if its left child has the same level.
    #
    # @param [Tree::AATree::Node] node The node to skew.
    # @return [Tree::AATree::Node] The new subtree root.
    def skew(node)
      left = node.left
      return node unless left && left.level == node.level

      rotate_right(node)
    end

    # Rotate a node left if its right-right grandchild has the same level.
    #
    # @param [Tree::AATree::Node] node The node to split.
    # @return [Tree::AATree::Node] The new subtree root.
    def split(node)
      right = node.right
      return node unless right&.right&.level == node.level

      new_root = rotate_left(node)
      new_root.level += 1
      new_root
    end

    # Decrease the level after deletions when needed.
    #
    # @param [Tree::AATree::Node] node The node to update.
    # @return [Tree::AATree::Node] The updated node.
    def decrease_level(node)
      expected = [level_of(node.left), level_of(node.right)].min + 1
      return node unless expected < node.level

      node.level = expected
      node.right.level = expected if node.right && node.right.level > expected
      node
    end

    # Rotate a subtree left.
    #
    # @param [Tree::AATree::Node] node The rotation pivot.
    # @return [Tree::AATree::Node] The new subtree root.
    def rotate_left(node)
      pivot = node.right
      return node unless pivot

      node.right = pivot.left
      pivot.left = node
      pivot
    end

    # Rotate a subtree right.
    #
    # @param [Tree::AATree::Node] node The rotation pivot.
    # @return [Tree::AATree::Node] The new subtree root.
    def rotate_right(node)
      pivot = node.left
      return node unless pivot

      node.left = pivot.right
      pivot.right = node
      pivot
    end

    # Return the level for a node (nil nodes have level 0).
    #
    # @param [Tree::AATree::Node, nil] node The node to measure.
    # @return [Integer] The node level.
    def level_of(node)
      node&.level.to_i
    end

    # Return the minimum node in a subtree.
    #
    # @param [Tree::AATree::Node] node Subtree root.
    # @return [Tree::AATree::Node] The minimum node.
    def min_node(node)
      current = node
      current = current.left while current.left
      current
    end

    # Count entries in a subtree.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @return [Integer] Entry count.
    def count_entries(node)
      return 0 unless node

      1 + count_entries(node.left) + count_entries(node.right)
    end

    # In-order traversal of entries.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @yieldparam entry [Tree::AATree::Entry] Entry in traversal order.
    # @return [void]
    def inorder_entries(node, &)
      return unless node

      inorder_entries(node.left, &)
      yield node.entry
      inorder_entries(node.right, &)
    end

    # Pre-order traversal of entries.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @yieldparam entry [Tree::AATree::Entry] Entry in traversal order.
    # @return [void]
    def preorder_entries(node, &)
      return unless node

      yield node.entry
      preorder_entries(node.left, &)
      preorder_entries(node.right, &)
    end

    # Post-order traversal of entries.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @yieldparam entry [Tree::AATree::Entry] Entry in traversal order.
    # @return [void]
    def postorder_entries(node, &)
      return unless node

      postorder_entries(node.left, &)
      postorder_entries(node.right, &)
      yield node.entry
    end

    # Breadth-first traversal of entries.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @yieldparam entry [Tree::AATree::Entry] Entry in traversal order.
    # @return [void]
    def breadth_entries(node, &)
      return unless node

      queue = [node]
      index = 0
      while index < queue.length
        current = queue[index]
        index += 1
        yield current.entry
        queue << current.left if current.left
        queue << current.right if current.right
      end
    end

    # Serialize a subtree to a hash representation.
    #
    # @param [Tree::AATree::Node, nil] node Subtree root.
    # @return [Hash, nil] Hash representation of the subtree.
    def node_to_h(node)
      return nil unless node

      {
        entry: { key: node.entry.key, value: node.entry.value },
        level: node.level,
        left: node_to_h(node.left),
        right: node_to_h(node.right)
      }
    end

    # Hydrate a subtree from a hash representation.
    #
    # @param [Hash, nil] hash Hash representation of an AA tree node.
    # @return [Tree::AATree::Node, nil] The hydrated node.
    def node_from_h(hash)
      return nil unless hash
      raise ArgumentError, 'AA tree node hash input must be a Hash.' unless hash.is_a?(Hash)

      entry_hash = fetch_hash_value(hash, :entry, required: true)
      key = fetch_hash_value(entry_hash, :key, required: true)
      value = fetch_hash_value(entry_hash, :value)
      level = fetch_hash_value(hash, :level, 1)
      left = node_from_h(fetch_hash_value(hash, :left))
      right = node_from_h(fetch_hash_value(hash, :right))
      Node.new(Entry.new(key, value), level, left, right)
    end

    # Fetch a value from a hash using symbol or string keys.
    #
    # @param [Hash] hash Hash to query.
    # @param [Symbol] key Preferred symbol key.
    # @param [Object, nil] default Default value if missing.
    # @param [Boolean] required Whether to raise if missing.
    # @return [Object, nil] The fetched value.
    def fetch_hash_value(hash, key, default = nil, required: false)
      return hash[key] if hash.key?(key)

      string_key = key.to_s
      return hash[string_key] if hash.key?(string_key)
      return default unless required

      raise KeyError, "key not found: #{key.inspect}"
    end

    # Compare two keys using Ruby's +<=>+.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] -1, 0, or 1 depending on ordering.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'AA-tree keys must be comparable using <=>.' if result.nil?

      result
    end

    # Validate that a key is non-nil.
    #
    # @param [Object] key The key to validate.
    # @return [void]
    def validate_key!(key)
      raise ArgumentError, 'AA-tree key must not be nil.' if key.nil?
    end
  end
end
