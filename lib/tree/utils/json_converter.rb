# json_converter.rb - This file is part of the RubyTree package.
#
# = json_converter.rb - Provides conversion to and from JSON.
#
# Author::  Anupam Sengupta (anupamsg@gmail.com)
#
# Time-stamp: <2023-12-27 12:46:07 anupam>
#
# Copyright (C) 2012, 2013, 2014, 2015, 2022, 2023 Anupam Sengupta <anupamsg@gmail.com>
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
    #
    # Every serialized node carries its Ruby class name under the +json_class+
    # key. With the json gem 2.x this is the key the gem inspects itself when
    # parsing with +create_additions: true+. The json gem 3.x removed that
    # option together with the +JSON.create_id+ accessor, so RubyTree emits the
    # key on its own and rebuilds the nodes through {ClassMethods#from_json},
    # which relies on the +on_load+ parser callback available in both the json
    # gem 2.x and 3.x.
    module JSONConverter
      # The hash key which carries the Ruby class name of a serialized node.
      # Equals the default +JSON.create_id+ of the json gem 2.x, so documents
      # written by earlier RubyTree versions stay readable.
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

        json_hash['children'] = children if children?

        json_hash
      end

      # Creates a JSON representation of this node including all it's children.
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
        # The nodes are rebuilt from the hashes tagged with the +json_class+
        # key, see {#json_on_load} for the rules. The document root must
        # describe a node of this class, or of one of its subclasses.
        #
        # This works with both the json gem 2.x and 3.x. With the json gem 2.x
        # the legacy +JSON.parse(json_string, create_additions: true)+ keeps
        # working as well, but the json gem 3.x removed that option.
        #
        # @param [String] source The JSON document to parse.
        #
        # @return [Tree::TreeNode] The root node of the parsed tree.
        #
        # @raise [ArgumentError] This exception is raised if the document does
        #                        not describe a node of this class.
        #
        # @raise [JSON::ParserError] This exception is raised if the document
        #                            is not valid JSON.
        #
        # @see #json_on_load
        # @see JSONConverter#to_json
        def from_json(source)
          tree = JSON.parse(source, on_load: method(:json_on_load).to_proc)
          return tree if tree.is_a?(self)

          raise ArgumentError, "JSON document does not describe a #{self} tree"
        end

        # Rebuilds a node from its parsed JSON hash. This is the +on_load+
        # callback for the parser of the json gem, used by {#from_json} and
        # available for custom parser setups (the parser expects a +Proc+):
        #
        #   on_load = Tree::TreeNode.method(:json_on_load).to_proc
        #   tree = JSON::Coder.new(on_load: on_load).load(json_string)
        #
        # The parser invokes the callback for every parsed value, innermost
        # first, so the +children+ of a node hash are already nodes by the
        # time the hash of their parent arrives here. Only hashes whose
        # +json_class+ names this class or one of its subclasses are turned
        # into nodes, any other value is returned untouched. This keeps the
        # deserialization scoped to tree nodes, unlike the global
        # +create_additions+ mechanism of the json gem 2.x which instantiated
        # any class named in a document.
        #
        # @param [Object] object A value produced by the JSON parser.
        #
        # @return [Tree::TreeNode, Object] The node for a tagged hash, or the
        #                                  unchanged value otherwise.
        #
        # @see #from_json
        # @see #json_create
        def json_on_load(object)
          return object unless object.is_a?(Hash)

          node_class = json_node_class(object[JSON_CLASS_KEY])
          node_class ? node_class.json_create(object) : object
        end

        # Resolves the class named by a +json_class+ tag, limited to this
        # class and its subclasses.
        #
        # @param [String, nil] class_name The class name found in the tag.
        #
        # @return [Class, nil] The node class, or +nil+ when the tag is
        #                      missing, unknown or names a foreign class.
        def json_node_class(class_name)
          return nil unless class_name.is_a?(String)

          node_class = Object.const_get(class_name)
          node_class if node_class.is_a?(Class) && node_class <= self
        rescue NameError
          nil
        end

        # Helper method to create a Tree::TreeNode instance from the JSON hash
        # representation.  Note that this method should *NOT* be called directly.
        # Instead, to convert a JSON document back to a tree, do:
        #
        #   tree = Tree::TreeNode.from_json(the_json_string)
        #
        # With the json gem 2.x this method also serves as the hook of the
        # +create_additions+ mechanism, so the legacy
        # +JSON.parse(the_json_string, create_additions: true)+ keeps working
        # there. The json gem 3.x removed that mechanism.
        #
        # @author Dirk Breuer (http://github.com/railsbros-dirk)
        # @since 0.7.0
        #
        # @param [Hash] json_hash The JSON hash to convert from.
        #
        # @return [Tree::TreeNode] The created tree.
        #
        # @see #from_json
        # @see #json_on_load
        # @see JSONConverter#to_json
        def json_create(json_hash)
          node = new(json_hash['name'], json_hash['content'])

          json_hash['children']&.each do |child|
            node << child
          end

          node
        end
      end
    end
  end
end
