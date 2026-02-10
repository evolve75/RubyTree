# example_trie.rb - This file is part of the RubyTree package.
#
# = example_trie.rb - Basic usage of Tree::TrieNode.
#
# Provides a short, runnable example of prefix lookups and deletes.
#
# Structure:
#
#   (root)
#    / \
#   c   d
#   |
#   a
#   |
#   t
#
# Author:: Anupam Sengupta (https://github.com/evolve75)
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
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

# Load JSON for parsing serialized trees.
require 'json'
# Load the trie implementation.
require 'tree/trie'

# Create the root node.
root = Tree::TrieNode.new('')
# Insert words with the natural shovel syntax.
root << 'cat'
root << 'd'

# Check if a word exists.
puts "include? cat: #{root.include?('cat')}"

# Check for a prefix.
puts "prefix? c: #{root.prefix?('c')}"

# List words with a prefix.
puts "words with 'c': #{root.words_with_prefix('c').inspect}"

# Delete a word.
root.delete('cat')
# Confirm deletion.
puts "include? cat: #{root.include?('cat')}"

# Serialize to JSON.
serialized_json = root.to_json
# Parse JSON back into a trie instance.
rebuilt_from_json = JSON.parse(serialized_json, create_additions: true)
# Show the rebuilt words for prefix.
puts "from_json words with 'd': #{rebuilt_from_json.words_with_prefix('d').inspect}"
