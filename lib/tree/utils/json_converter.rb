# json_converter.rb - This file is part of the RubyTree package.
#
# = json_converter.rb - Provides conversion to and from JSON.
#
# Author::  Anupam Sengupta (anupamsg@gmail.com)
#
# Time-stamp: <2023-12-27 12:46:07 anupam>
#
# Copyright (C) 2012-2026 Anupam Sengupta <anupamsg@gmail.com>
#
# All rights reserved.
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
  module Utils
    # Provides utility methods to convert a {Tree::TreeNode} to and from
    # JSON[http://flori.github.com/json/].
    module JSONConverter
      # The hash key containing the class name for a serialized tree node.
      # This matches the json gem 2.x default and preserves the existing format.
      JSON_CLASS_KEY = 'json_class'

      # Extend the base class with the converter class methods.
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @!group Converting to/from JSON

      # Creates a JSON ready Hash for the #to_json method.
      #
      # @author Eric Cline (https://github.com/escline)
      # @since 0.8.3
      #
      # @return A hash based representation of the JSON
      #
      # Rails uses JSON in ActiveSupport, and all Rails JSON encoding goes through
      # +as_json+.
      #
      # @param [Object] _options
      #
      # @see #to_json
      # @see http://stackoverflow.com/a/6880638/273808
      # noinspection RubyUnusedLocalVariable
      def as_json(_options = {})
        json_hash = {
          name: name,
          content: content,
          JSON_CLASS_KEY => self.class.name
        }

        compact_children = children_compact
        json_hash['children'] = compact_children if compact_children.any?

        json_hash
      end

      # Creates a JSON representation of this node including all its children.
      # This requires the JSON gem to be available, or else the operation fails with
      # a warning message.  Uses the Hash output of #as_json method.
      #
      # @author Dirk Breuer (http://github.com/railsbros-dirk)
      # @since 0.7.0
      #
      # @return The JSON representation of this subtree.
      #
      # @see ClassMethods#from_json
      # @see #as_json
      # @see http://flori.github.com/json
      def to_json(*args)
        as_json.to_json(*args)
      end

      # ClassMethods for the {JSONConverter} module. Will become class methods in
      # the +include+ target.
      module ClassMethods
        # Parses a JSON document and returns the tree it describes.
        #
        #   tree = Tree::TreeNode.from_json(json_string)
        #
        # This works with both the json gem 2.x and 3.x. It rebuilds hashes
        # only in the tree's +children+ arrays, leaving node content intact.
        # The legacy +JSON.parse(json_string, create_additions: true)+ form
        # remains available with json 2.x; json 3.x removed that option.
        #
        # @param [String] source The JSON document to parse.
        #
        # @return [Tree::TreeNode] The parsed root node.
        #
        # @raise [ArgumentError] The document root does not describe this class
        #                        or one of its subclasses.
        # @raise [JSON::ParserError] The document is not valid JSON.
        #
        # @see #json_rebuild_nodes
        # @see JSONConverter#to_json
        def from_json(source)
          tree = json_rebuild_nodes(JSON.parse(source))
          return tree if tree.is_a?(self)

          raise ArgumentError, "JSON document does not describe a #{self} tree"
        end

        # Resolves a json_class tag to this class or one of its subclasses.
        #
        # @param [String, nil] class_name The class name from a JSON tag.
        #
        # @return [Class, nil] The matching tree node class, or +nil+.
        def json_node_class(class_name)
          return nil unless class_name.is_a?(String)

          node_class = Object.const_get(class_name)
          node_class if node_class.is_a?(Class) && node_class <= self
        rescue NameError
          nil
        end
        private :json_node_class

        # Helper method to create a Tree::TreeNode instance from the JSON hash
        # representation.  Note that this method should *NOT* be called directly.
        # Instead, to convert the JSON hash back to a tree, do:
        #
        #   tree = Tree::TreeNode.from_json(json_string)
        #
        # This operation requires the {JSON gem}[http://flori.github.com/json/] to
        # be available, or else the operation fails with a warning message.
        #
        # With json 2.x, this method also serves the legacy +create_additions+
        # parser hook. json 3.x removed that mechanism.
        #
        # @author Dirk Breuer (http://github.com/railsbros-dirk)
        # @since 0.7.0
        #
        # @param [Hash] json_hash The JSON hash to convert from.
        #
        # @return [Tree::TreeNode] The created tree.
        #
        # @see #from_json
        # @see JSONConverter#to_json
        # @see http://flori.github.com/json
        def json_create(json_hash)
          node = new(json_hash['name'], json_hash['content'])

          json_hash['children']&.each do |child|
            next unless child

            node.add(child)
          end

          node
        end

        private

        # Rebuilds hashes reached through serialized child arrays. This leaves
        # arbitrary node content untouched even when it contains +json_class+.
        #
        # @param [Object] object A value parsed from JSON.
        #
        # @return [Object] A rebuilt node or the unchanged value.
        #
        # @see #from_json
        def json_rebuild_nodes(object)
          return object unless object.is_a?(Hash)

          node_class = json_node_class(object[JSON_CLASS_KEY])
          return object unless node_class

          node_data = object.dup
          if node_data['children'].is_a?(Array)
            node_data['children'] = node_data['children'].map do |child|
              json_rebuild_nodes(child)
            end
          end

          node_class.json_create(node_data)
        end
      end
    end
  end
end
