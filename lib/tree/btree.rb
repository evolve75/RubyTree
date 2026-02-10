# btree.rb - This file is part of the RubyTree package.
#
# = btree.rb - An implementation of the B-tree data structure.
#
# Provides a B-tree for ordered insert/search/delete operations.
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
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\"
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
  # Provides a B-tree implementation for ordered insert/search/delete operations.
  #
  # This implementation stores key/value pairs in each node and maintains B-tree
  # invariants using a configurable minimum degree.
  #
  # This class does not inherit from {Tree::TreeNode} and does not
  # expose parent/child navigation APIs. B-tree nodes hold multiple
  # entries and children, so many of the TreeNode mixins do not apply.
  # Instead, this class offers traversal helpers and key/value
  # accessors that align with B-tree semantics.
  #
  # The public API mirrors TreeNode where it makes sense (Enumerable iteration,
  # comparison via +<=>+, traversal helpers, and JSON/hash serialization), but
  # it intentionally omits TreeNode features that depend on single-entry nodes.
  #
  # Indices are zero-based for public methods that accept indexes.
  #
  class BTree
    include Enumerable
    include Comparable

    # Key/value entry for the B-tree.
    Entry = Struct.new(:key, :value)

    # Internal node representation for the B-tree.
    class Node
      # @!attribute [rw] entries
      # Entries stored in this node.
      #
      # @return [Array<Tree::BTree::Entry>] Ordered entries.
      attr_accessor :entries

      # @!attribute [rw] children
      # Child nodes for this node.
      #
      # @return [Array<Tree::BTree::Node>] Child nodes.
      attr_accessor :children

      # @!attribute [rw] leaf
      # +true+ if this node is a leaf.
      #
      # @return [Boolean] Leaf flag.
      attr_accessor :leaf

      # Create a B-tree node.
      #
      # @param [Boolean] leaf +true+ if this node is a leaf.
      def initialize(leaf: true)
        @leaf = leaf
        @entries = []
        @children = []
      end
    end

    # @!attribute [r] min_degree
    # Minimum degree (t) of the B-tree.
    #
    # Each node (except root) has at least t-1 entries and at most 2t-1 entries.
    #
    # @return [Integer] The minimum degree.
    attr_reader :min_degree

    # @!attribute [r] root
    # Root node of the B-tree.
    #
    # @return [Tree::BTree::Node] The root node.
    attr_reader :root

    # Create a B-tree with the specified minimum degree.
    #
    # @param [Integer] min_degree Minimum degree (t). Must be >= 2.
    # @param [Array, nil] entries Optional initial entries.
    #
    # @raise [ArgumentError] If min_degree is invalid.
    def initialize(min_degree = 2, entries = nil)
      validate_min_degree!(min_degree)
      @min_degree = min_degree
      @root = Node.new

      return unless entries

      entries.each do |entry|
        insert(entry[:key], entry[:value])
      end
    end

    # Insert a key/value pair into the B-tree.
    #
    # @param [Object] key The key to insert. Must be comparable via +<=>+.
    # @param [Object] value The value associated with the key.
    #
    # @return [Tree::BTree::Entry] The inserted entry.
    #
    # @raise [ArgumentError] If the key is +nil+ or not comparable.
    def insert(key, value = nil)
      validate_key!(key)

      existing = search_entry(root, key)
      if existing
        existing.value = value
        return existing
      end

      if root.entries.length == max_entries
        old_root = root
        @root = Node.new(leaf: false)
        root.children << old_root
        split_child(root, 0)
      end

      insert_non_full(root, Entry.new(key, value))
    end

    # Insert an entry using natural +<<+ syntax.
    #
    # @param [Array, Hash, Tree::BTree::Entry] entry Input entry as
    #   +[key, value]+, +{ key:, value: }+, or {Tree::BTree::Entry}.
    # @return [Tree::BTree::Entry] The inserted entry.
    #
    # @raise [ArgumentError] If the input format is unsupported.
    def <<(entry)
      key, value = entry_to_pair(entry)
      insert(key, value)
    end

    # Search for a key in the B-tree.
    #
    # @param [Object] key The key to search for.
    #
    # @return [Object, nil] The matching value, or +nil+.
    def search(key)
      validate_key!(key)

      entry = search_entry(root, key)
      entry&.value
    end

    # Delete a key from the B-tree.
    #
    # @param [Object] key The key to delete.
    #
    # @return [Object, nil] The removed value, or +nil+ if not found.
    def delete(key)
      validate_key!(key)
      removed = delete_from_node(root, key)

      @root = root.children.first if root.entries.empty? && !root.leaf

      removed&.value
    end

    # Return the number of entries stored in the B-tree.
    #
    # @return [Integer] The number of entries in the tree.
    def size
      count_entries(root)
    end

    # Convenience synonym for {#size}.
    #
    # @return [Integer] The number of entries in the tree.
    def length
      size
    end

    # Height of the tree measured in edges from root to leaf.
    #
    # @return [Integer] The height of the tree.
    def height
      node_height(root)
    end

    # Iterate over entries in sorted key order.
    #
    # @yieldparam entry [Tree::BTree::Entry] Each entry in order.
    #
    # @return [Tree::BTree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def each(&)
      return to_enum(:each) unless block_given?

      inorder_entries(root, &)
      self
    end

    # Pre-order traversal over entries.
    #
    # @yieldparam entry [Tree::BTree::Entry] Each entry in pre-order.
    #
    # @return [Tree::BTree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def preordered_each(&)
      return to_enum(:preordered_each) unless block_given?

      preorder_entries(root, &)
      self
    end

    # Post-order traversal over entries.
    #
    # @yieldparam entry [Tree::BTree::Entry] Each entry in post-order.
    #
    # @return [Tree::BTree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def postordered_each(&)
      return to_enum(:postordered_each) unless block_given?

      postorder_entries(root, &)
      self
    end

    # Breadth-first traversal over entries.
    #
    # @yieldparam entry [Tree::BTree::Entry] Each entry in breadth-first order.
    #
    # @return [Tree::BTree] The receiver, if a block is given.
    # @return [Enumerator] An enumerator, if no block is given.
    def breadth_each(&)
      return to_enum(:breadth_each) unless block_given?

      breadth_entries(root, &)
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
    # @return [Hash] Hash representation of the B-tree.
    def to_h
      {
        min_degree: min_degree,
        root: node_to_h(root)
      }
    end

    # Build a B-tree from a Hash representation.
    #
    # @param [Hash] hash Hash representation of a B-tree.
    # @return [Tree::BTree] The constructed tree.
    def self.from_hash(hash)
      raise ArgumentError, 'B-tree hash input must be a Hash.' unless hash.is_a?(Hash)

      min_degree = hash.fetch(:min_degree, hash.fetch('min_degree', 2))
      tree = new(min_degree)
      root_hash = hash.fetch(:root, hash.fetch('root', nil))
      raise ArgumentError, 'B-tree hash must include a root node.' unless root_hash

      tree.instance_variable_set(:@root, tree.send(:node_from_h, root_hash))
      tree
    end

    # JSON serialization for the B-tree.
    #
    # @param [Hash] _options JSON serialization options.
    # @return [Hash] Hash representation for JSON serialization.
    def as_json(_options = {})
      to_h
    end

    # Serialize the B-tree to JSON.
    #
    # @param [Array] args JSON.generate arguments.
    # @return [String] JSON representation of the tree.
    def to_json(*args)
      JSON.generate(as_json, *args)
    end

    # Create a B-tree from a JSON hash.
    #
    # @param [Hash] json_hash JSON hash representation.
    # @return [Tree::BTree] The constructed tree.
    def self.json_create(json_hash)
      from_hash(json_hash)
    end

    # Compare B-trees by their in-order key/value pairs.
    #
    # @param [Tree::BTree] other The B-tree to compare.
    # @return [Integer, nil] -1, 0, 1, or +nil+ if not comparable.
    def <=>(other)
      return nil unless other.is_a?(Tree::BTree)

      to_a <=> other.to_a
    end

    private

    # Convert a supported entry input into a key/value pair.
    #
    # @param [Array, Hash, Tree::BTree::Entry] entry Input entry.
    # @return [Array<Object, Object>] The +[key, value]+ pair.
    #
    # @raise [ArgumentError] If the input format is unsupported.
    def entry_to_pair(entry)
      return [entry.key, entry.value] if entry.is_a?(Entry)
      return array_entry_to_pair(entry) if entry.is_a?(Array)
      return hash_entry_to_pair(entry) if entry.is_a?(Hash)

      raise ArgumentError, 'B-tree << expects [key, value], { key:, value: }, or Entry.'
    end

    # Convert an array entry into a key/value pair.
    #
    # @param [Array] entry Input as +[key, value]+.
    # @return [Array<Object, Object>] The +[key, value]+ pair.
    #
    # @raise [ArgumentError] If the array shape is invalid.
    def array_entry_to_pair(entry)
      raise ArgumentError, 'B-tree << expects [key, value].' unless entry.length == 2

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
      raise ArgumentError, 'B-tree << expects { key:, value: }.' unless has_symbol_key || has_string_key

      key = has_symbol_key ? entry[:key] : entry['key']
      value = entry.key?(:value) ? entry[:value] : entry['value']
      [key, value]
    end

    # Maximum entries per node.
    #
    # @return [Integer] The maximum entry count.
    def max_entries
      (2 * min_degree) - 1
    end

    # Minimum entries per node (excluding root).
    #
    # @return [Integer] The minimum entry count.
    def min_entries
      min_degree - 1
    end

    # Validate the minimum degree for the tree.
    #
    # @param [Integer] min_degree The degree to validate.
    # @raise [ArgumentError] If the minimum degree is invalid.
    def validate_min_degree!(min_degree)
      return if min_degree.is_a?(Integer) && min_degree >= 2

      raise ArgumentError, 'B-tree minimum degree must be an integer >= 2.'
    end

    # Validate a key for insertion/search operations.
    #
    # @param [Object] key The key to validate.
    # @raise [ArgumentError] If the key is nil or not comparable.
    def validate_key!(key)
      raise ArgumentError, 'B-tree key must not be nil.' if key.nil?

      compare_keys(key, key)
    end

    # Compare two keys using the +<=>+ operator.
    #
    # @param [Object] left The left key.
    # @param [Object] right The right key.
    # @return [Integer] Comparison result from +<=>+.
    # @raise [ArgumentError] If keys are not comparable.
    def compare_keys(left, right)
      result = left <=> right
      raise ArgumentError, 'B-tree keys must be comparable using <=>.' if result.nil?

      result
    end

    # Search for a matching entry in a node subtree.
    #
    # @param [Tree::BTree::Node] node Node to search.
    # @param [Object] key The key to search for.
    # @return [Tree::BTree::Entry, nil] The found entry, if any.
    def search_entry(node, key)
      index = node.entries.index { |entry| compare_keys(key, entry.key) <= 0 } || node.entries.length
      return node.entries[index] if index < node.entries.length && compare_keys(key, node.entries[index].key).zero?

      return nil if node.leaf

      search_entry(node.children[index], key)
    end

    # Insert an entry into a non-full node.
    #
    # @param [Tree::BTree::Node] node Node that is not full.
    # @param [Tree::BTree::Entry] entry Entry to insert.
    # @return [Tree::BTree::Entry] The inserted entry.
    def insert_non_full(node, entry)
      index = node.entries.length - 1

      if node.leaf
        node.entries << entry
        while index >= 0 && compare_keys(entry.key, node.entries[index].key).negative?
          node.entries[index + 1] = node.entries[index]
          index -= 1
        end
        node.entries[index + 1] = entry
        return entry
      end

      index -= 1 while index >= 0 && compare_keys(entry.key, node.entries[index].key).negative?
      index += 1

      if node.children[index].entries.length == max_entries
        split_child(node, index)
        index += 1 if compare_keys(entry.key, node.entries[index].key).positive?
      end

      insert_non_full(node.children[index], entry)
    end

    # Split a full child into two nodes and promote the middle entry.
    #
    # @param [Tree::BTree::Node] parent Parent node containing the child.
    # @param [Integer] index Index of the child to split.
    # @return [void]
    def split_child(parent, index)
      full_child = parent.children[index]
      sibling = Node.new(leaf: full_child.leaf)

      middle_entry = full_child.entries[min_degree - 1]
      sibling.entries = full_child.entries[min_degree..]
      full_child.entries = full_child.entries[0...(min_degree - 1)]

      unless full_child.leaf
        sibling.children = full_child.children[min_degree..]
        full_child.children = full_child.children[0...min_degree]
      end

      parent.entries.insert(index, middle_entry)
      parent.children.insert(index + 1, sibling)
    end

    # Delete a key from a node subtree.
    #
    # @param [Tree::BTree::Node] node Node to delete from.
    # @param [Object] key The key to delete.
    # @return [Tree::BTree::Entry, nil] The deleted entry, if any.
    def delete_from_node(node, key)
      index = node.entries.index { |entry| compare_keys(key, entry.key) <= 0 } || node.entries.length

      if index < node.entries.length && compare_keys(key, node.entries[index].key).zero?
        return delete_from_leaf(node, index) if node.leaf

        return delete_from_internal(node, index)
      end

      return nil if node.leaf

      child_index = index
      ensure_child_has_entries(node, child_index)
      delete_from_node(node.children[child_index], key)
    end

    # Delete an entry from a leaf node.
    #
    # @param [Tree::BTree::Node] node Leaf node to delete from.
    # @param [Integer] index Index of the entry to delete.
    # @return [Tree::BTree::Entry] The deleted entry.
    def delete_from_leaf(node, index)
      node.entries.delete_at(index)
    end

    # Delete an entry from an internal node.
    #
    # @param [Tree::BTree::Node] node Internal node to delete from.
    # @param [Integer] index Index of the entry to delete.
    # @return [Tree::BTree::Entry] The deleted entry.
    def delete_from_internal(node, index)
      entry = node.entries[index]
      left_child = node.children[index]
      right_child = node.children[index + 1]

      if left_child.entries.length > min_entries
        predecessor = max_entry(left_child)
        node.entries[index] = predecessor
        delete_from_node(left_child, predecessor.key)
        return entry
      end

      if right_child.entries.length > min_entries
        successor = min_entry(right_child)
        node.entries[index] = successor
        delete_from_node(right_child, successor.key)
        return entry
      end

      merged = merge_children(node, index)
      delete_from_node(merged, entry.key)
      entry
    end

    # Ensure a child has enough entries to support deletion.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the child to normalize.
    # @return [void]
    def ensure_child_has_entries(node, index)
      child = node.children[index]
      return if child.entries.length > min_entries

      left_sibling = index.positive? ? node.children[index - 1] : nil
      right_sibling = index < node.children.length - 1 ? node.children[index + 1] : nil

      return if borrow_from_left_sibling?(node, index, left_sibling, child)
      return if borrow_from_right_sibling?(node, index, right_sibling, child)

      merge_index = left_sibling ? index - 1 : index
      merge_children(node, merge_index)
    end

    # Try to borrow from the left sibling if it has extra entries.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the child to borrow for.
    # @param [Tree::BTree::Node, nil] left_sibling Left sibling node.
    # @param [Tree::BTree::Node] child Child node to receive an entry.
    # @return [Boolean] +true+ if a borrow occurred.
    def borrow_from_left_sibling?(node, index, left_sibling, child)
      return false unless left_sibling && left_sibling.entries.length > min_entries

      borrow_from_left(node, index, left_sibling, child)
      true
    end

    # Try to borrow from the right sibling if it has extra entries.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the child to borrow for.
    # @param [Tree::BTree::Node, nil] right_sibling Right sibling node.
    # @param [Tree::BTree::Node] child Child node to receive an entry.
    # @return [Boolean] +true+ if a borrow occurred.
    def borrow_from_right_sibling?(node, index, right_sibling, child)
      return false unless right_sibling && right_sibling.entries.length > min_entries

      borrow_from_right(node, index, right_sibling, child)
      true
    end

    # Borrow an entry from the left sibling.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the child to borrow for.
    # @param [Tree::BTree::Node] left_sibling Left sibling node.
    # @param [Tree::BTree::Node] child Child node to receive an entry.
    # @return [void]
    def borrow_from_left(node, index, left_sibling, child)
      child.entries.unshift(node.entries[index - 1])
      node.entries[index - 1] = left_sibling.entries.pop
      child.children.unshift(left_sibling.children.pop) unless left_sibling.leaf
    end

    # Borrow an entry from the right sibling.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the child to borrow for.
    # @param [Tree::BTree::Node] right_sibling Right sibling node.
    # @param [Tree::BTree::Node] child Child node to receive an entry.
    # @return [void]
    def borrow_from_right(node, index, right_sibling, child)
      child.entries.push(node.entries[index])
      node.entries[index] = right_sibling.entries.shift
      child.children.push(right_sibling.children.shift) unless right_sibling.leaf
    end

    # Merge two adjacent children and pull down the separating entry.
    #
    # @param [Tree::BTree::Node] node Parent node.
    # @param [Integer] index Index of the left child.
    # @return [Tree::BTree::Node] The merged child.
    def merge_children(node, index)
      left_child = node.children[index]
      right_child = node.children[index + 1]

      left_child.entries << node.entries.delete_at(index)
      left_child.entries.concat(right_child.entries)
      left_child.children.concat(right_child.children) unless left_child.leaf

      node.children.delete_at(index + 1)
      left_child
    end

    # Find the minimum entry in a subtree.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @return [Tree::BTree::Entry] The minimum entry.
    def min_entry(node)
      current = node
      current = current.children.first until current.leaf
      current.entries.first
    end

    # Find the maximum entry in a subtree.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @return [Tree::BTree::Entry] The maximum entry.
    def max_entry(node)
      current = node
      current = current.children.last until current.leaf
      current.entries.last
    end

    # Count entries in a subtree.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @return [Integer] Entry count.
    def count_entries(node)
      total = node.entries.length
      return total if node.leaf

      node.children.each { |child| total += count_entries(child) }
      total
    end

    # In-order traversal of entries.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @yieldparam entry [Tree::BTree::Entry] Entry in traversal order.
    # @return [void]
    def inorder_entries(node, &)
      if node.leaf
        node.entries.each(&)
        return
      end

      node.entries.each_with_index do |entry, index|
        inorder_entries(node.children[index], &)
        yield entry
      end
      inorder_entries(node.children[node.entries.length], &)
    end

    # Pre-order traversal of entries.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @yieldparam entry [Tree::BTree::Entry] Entry in traversal order.
    # @return [void]
    def preorder_entries(node, &)
      node.entries.each(&)
      return if node.leaf

      node.children.each { |child| preorder_entries(child, &) }
    end

    # Post-order traversal of entries.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @yieldparam entry [Tree::BTree::Entry] Entry in traversal order.
    # @return [void]
    def postorder_entries(node, &)
      node.children.each { |child| postorder_entries(child, &) } unless node.leaf
      node.entries.each(&)
    end

    # Breadth-first traversal of entries.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @yieldparam entry [Tree::BTree::Entry] Entry in traversal order.
    # @return [void]
    def breadth_entries(node, &)
      queue = [node]
      index = 0
      while index < queue.length
        current = queue[index]
        index += 1
        current.entries.each(&)
        next if current.leaf

        queue.concat(current.children)
      end
    end

    # Serialize a subtree to a hash representation.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @return [Hash] Hash representation of the subtree.
    def node_to_h(node)
      {
        entries: node.entries.map { |entry| { key: entry.key, value: entry.value } },
        children: node.children.map { |child| node_to_h(child) },
        leaf: node.leaf
      }
    end

    # Hydrate a subtree from a hash representation.
    #
    # @param [Hash] hash Hash representation of a B-tree node.
    # @return [Tree::BTree::Node] The hydrated node.
    # @raise [ArgumentError] If the hash is not a Hash.
    def node_from_h(hash)
      raise ArgumentError, 'B-tree node hash input must be a Hash.' unless hash.is_a?(Hash)

      leaf = fetch_required_key(hash, :leaf, 'leaf')
      node = Node.new(leaf: leaf)
      entries = fetch_optional_key(hash, :entries, 'entries', [])
      node.entries = entries.map do |entry|
        key = fetch_required_key(entry, :key, 'key')
        value = fetch_optional_key(entry, :value, 'value', nil)
        Entry.new(key, value)
      end
      children = fetch_optional_key(hash, :children, 'children', [])
      node.children = children.map { |child| node_from_h(child) }
      node
    end

    # Compute the height of a subtree in edges.
    #
    # @param [Tree::BTree::Node] node Subtree root.
    # @return [Integer] Height measured in edges.
    def node_height(node)
      return 0 if node.leaf

      1 + node.children.map { |child| node_height(child) }.max
    end

    # Fetch a required value using a symbol or string key.
    #
    # @param [Hash] hash The hash to query.
    # @param [Symbol] symbol_key The symbol key to check first.
    # @param [String] string_key The string key to check second.
    # @return [Object] The value for the key.
    # @raise [KeyError] If neither key exists.
    def fetch_required_key(hash, symbol_key, string_key)
      return hash[symbol_key] if hash.key?(symbol_key)
      return hash[string_key] if hash.key?(string_key)

      raise KeyError, "key not found: #{string_key.inspect}"
    end

    # Fetch an optional value using a symbol or string key.
    #
    # @param [Hash] hash The hash to query.
    # @param [Symbol] symbol_key The symbol key to check first.
    # @param [String] string_key The string key to check second.
    # @param [Object] default The default value to return if neither key exists.
    # @return [Object] The value for the key.
    def fetch_optional_key(hash, symbol_key, string_key, default)
      return hash[symbol_key] if hash.key?(symbol_key)
      return hash[string_key] if hash.key?(string_key)

      default
    end
  end
end
