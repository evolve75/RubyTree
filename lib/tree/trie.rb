# trie.rb - This file is part of the RubyTree package.
#
# = trie.rb - An implementation of the trie (prefix tree) data structure.
#
# Provides a trie data structure for string key storage with prefix lookups.
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

require_relative '../tree'

module Tree
  # Provides a Trie (prefix tree) implementation. Each node represents a single
  # character and word termination is tracked via a terminal flag.
  #
  # @note Trie nodes are inserted according to character order in the string,
  #   not by index. Each child name is a single-character string.
  #
  # This inherits from the {Tree::TreeNode} class.
  #
  class TrieNode < TreeNode
    # @!group Core Attributes

    # @!attribute [r] terminal
    # Indicates whether this node terminates a stored word.
    attr_reader :terminal

    # Create a trie node.
    #
    # @param [String, Symbol] name Name of the node (usually a single character).
    # @param [Object] content Optional content payload.
    # @param [Hash] options Options passed to the base {Tree::TreeNode}.
    #
    # @see Tree::TreeNode#initialize
    def initialize(name, content = nil, options = nil)
      super
      @terminal = false
    end

    # Returns +true+ if this node terminates a stored word.
    #
    # @return [Boolean] +true+ if this is a terminal node.
    def terminal?
      @terminal == true
    end

    # Inserts a word into the trie.
    #
    # @param [String] word The word to insert.
    #
    # @return [Tree::TrieNode] The terminal node for the inserted word.
    #
    # @raise [ArgumentError] If the word is empty or not a string.
    def insert(word)
      validate_word!(word)
      current = root

      word.each_char do |char|
        child = current[char]
        unless child
          child = self.class.new(char, nil, { checks: current.checks_enabled? })
          current.add(child)
        end
        current = child
      end

      current.send(:terminal=, true)
      current
    end

    # Insert a word into the trie using natural +<<+ syntax.
    #
    # This overrides {Tree::TreeNode#<<}. For trie nodes, +<<+ inserts a word
    # (string) instead of attaching a child node directly.
    #
    # @param [String] word The word to insert.
    # @return [Tree::TrieNode] The terminal node for the inserted word.
    #
    # @raise [ArgumentError] If the word is empty or not a string.
    #
    # @see #insert
    def <<(word)
      insert(word)
    end

    # Returns +true+ if the trie includes the specified word.
    #
    # @param [String] word The word to look up.
    # @return [Boolean] +true+ if the word exists.
    def include?(word)
      validate_word!(word)
      node = find_node(word)
      node&.terminal? == true
    end

    # Alias for {#include?} to support search-oriented naming.
    alias search include?

    # Returns +true+ if the trie includes the specified prefix.
    #
    # @param [String] prefix The prefix to look up.
    # @return [Boolean] +true+ if the prefix exists.
    def prefix?(prefix)
      validate_prefix!(prefix)
      !!find_node(prefix)
    end

    # Delete a word from the trie.
    #
    # @param [String] word The word to delete.
    # @return [Boolean] +true+ if the word was deleted.
    def delete?(word)
      validate_word!(word)
      node = find_node(word)
      return false unless node&.terminal?

      node.send(:terminal=, false)
      prune_upwards(node)
      true
    end

    # Alias for {#delete?}.
    alias delete delete?

    # Return all words that match the specified prefix.
    #
    # @param [String] prefix The prefix to match.
    # @param [Integer, nil] limit Maximum number of words to return.
    # @return [Array<String>] The matching words.
    def words_with_prefix(prefix, limit: nil)
      validate_prefix!(prefix)
      start = find_node(prefix)
      return [] unless start

      results = []
      collect_words(start, prefix, results, limit)
      results
    end

    private

    # Set the terminal flag.
    #
    # @param [Boolean] value The terminal flag value.
    # @return [void]
    def terminal=(value)
      @terminal = value == true
    end

    # Validate that the word is a non-empty string.
    #
    # @param [String] word The word to validate.
    # @return [void]
    def validate_word!(word)
      raise ArgumentError, 'Word must be a non-empty string.' unless word.is_a?(String) && !word.empty?
    end

    # Validate that the prefix is a string (can be empty).
    #
    # @param [String] prefix The prefix to validate.
    # @return [void]
    def validate_prefix!(prefix)
      raise ArgumentError, 'Prefix must be a string.' unless prefix.is_a?(String)
    end

    # Find the node for a word or prefix.
    #
    # @param [String] value The word or prefix to search.
    # @return [Tree::TrieNode, nil] The terminal node if found.
    def find_node(value)
      current = root
      value.each_char do |char|
        current = current[char]
        return nil unless current
      end
      current
    end

    # Collect words under the subtree rooted at +node+.
    #
    # @param [Tree::TrieNode] node The starting node.
    # @param [String] prefix The prefix accumulated so far.
    # @param [Array<String>] results The results array to append to.
    # @param [Integer, nil] limit Maximum number of words to return.
    # @return [void]
    def collect_words(node, prefix, results, limit)
      return if limit_reached?(results, limit)

      results << prefix if node.terminal?
      return if limit_reached?(results, limit)

      node.children.each do |child|
        break if limit_reached?(results, limit)

        collect_words(child, prefix + child.name.to_s, results, limit)
      end
    end

    # Return +true+ if the results have reached the limit.
    #
    # @param [Array<String>] results The current results.
    # @param [Integer, nil] limit The maximum number of results.
    # @return [Boolean] +true+ if the limit has been reached.
    def limit_reached?(results, limit)
      limit && results.size >= limit
    end

    # Prune empty non-terminal nodes upwards.
    #
    # @param [Tree::TrieNode] node The node to start pruning from.
    # @return [void]
    def prune_upwards(node)
      current = node
      while current && !current.terminal? && current.leaf? && !current.root?
        parent = current.parent
        parent.remove!(current)
        current = parent
      end
    end
  end
end
