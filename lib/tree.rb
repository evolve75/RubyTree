# tree.rb - This file is part of the RubyTree package.
#
# = tree.rb - Generic implementation of an N-ary tree data structure.
#
# Provides a generic tree data structure with ability to
# store keyed node elements in the tree.  This implementation
# mixes in the Enumerable module.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#

# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
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

require 'tree/tree_deps'
require 'tree/utils/cache_methods'
require 'tree/utils/structure_methods'
require 'tree/utils/navigation_methods'
require 'tree/utils/traversal_methods'

# This module provides a *TreeNode* class whose instances are the primary
# objects for representing nodes in the tree.
#
# This module also acts as the namespace for all classes in the *RubyTree*
# package.
module Tree
  # == TreeNode Class Description
  #
  # This class models the nodes for an *N-ary* tree data structure. The
  # nodes are *named*, and have a place-holder for the node data (i.e.,
  # _content_ of the node). The node names are required to be *unique*
  # amongst the sibling/peer nodes. Note that the name is implicitly
  # used as an _ID_ within the data structure).
  #
  # The node's _content_ is *not* required to be unique across
  # different nodes in the tree, and can be +nil+ as well.
  #
  # The class provides various methods to navigate the tree, traverse
  # the structure, modify contents of the node, change position of the
  # node in the tree, and to make structural changes to the tree.
  #
  # A node can have any number of *child* nodes attached to it and
  # hence can be used to create N-ary trees.  Access to the child
  # nodes can be made in order (with the conventional left to right
  # access), or randomly.
  #
  # The node also provides direct access to its *parent* node as well
  # as other superior parents in the path to root of the tree.  In
  # addition, a node can also access its *sibling* nodes, if present.
  #
  # Note that while this implementation does not _explicitly_ support
  # directed graphs, the class itself makes no restrictions on
  # associating a node's *content* with multiple nodes in the tree.
  # However, having duplicate nodes within the structure is likely to
  # cause unpredictable behavior.
  #
  # == Example
  #
  # {include:file:examples/example_basic.rb}
  #
  # @author Anupam Sengupta
  # noinspection RubyTooManyMethodsInspection
  class TreeNode
    include Enumerable
    include Comparable
    include Tree::Utils::TreeMetricsHandler
    include Tree::Utils::TreePathHandler
    include Tree::Utils::JSONConverter
    include Tree::Utils::TreeMergeHandler
    include Tree::Utils::HashConverter
    include Tree::Utils::TreeCacheHandler
    include Tree::Utils::TreeStructureHandler
    include Tree::Utils::TreeNavigationHandler
    include Tree::Utils::TreeTraversalHandler

    # @!group Core Attributes

    # @!attribute [r] name
    #
    # Name of this node.  Expected to be unique within the tree.
    #
    # Note that the name attribute really functions as an *ID* within
    # the tree structure, and hence the uniqueness constraint is
    # required.
    #
    # This may be changed in the future, but for now it is best to
    # retain unique names within the tree structure, and use the
    # +content+ attribute for any non-unique node requirements.
    #
    # If you want to change the name, you probably want to call +rename+
    # instead. Note that +name=+ is a protected method.
    #
    # @see content
    # @see rename
    attr_accessor :name

    # @!attribute [rw] content
    # Content of this node.  Can be +nil+.  Note that there is no
    # uniqueness constraint related to this attribute.
    #
    # @see name
    attr_accessor :content

    # @!attribute [r] parent
    # Parent of this node.  Will be +nil+ for a root node.
    attr_reader   :parent
    protected :name=

    # @!attribute [r] root
    # Root node for the (sub)tree to which this node belongs.
    # A root node's root is itself.
    #
    # @return [Tree::TreeNode] Root of the (sub)tree.
    def root
      return @root_cache if @root_cache

      root_node = self
      root_node = root_node.parent until root_node.root?
      @root_cache = root_node
    end

    # @!attribute [r] root?
    # Returns +true+ if this is a root node.  Note that
    # orphaned children will also be reported as root nodes.
    #
    # @return [Boolean] +true+ if this is a root node.
    def root?
      @parent.nil?
    end

    alias is_root? root? # @todo: Aliased for eventual replacement

    # @!attribute [r] content?
    # +true+ if this node has content.
    #
    # @return [Boolean] +true+ if the node has content.
    def content?
      @content != nil
    end

    alias has_content? content? # @todo: Aliased for eventual replacement

    # @!attribute [r] leaf?
    # +true+ if this node is a _leaf_ - i.e., one without
    # any children.
    #
    # @return [Boolean] +true+ if this is a leaf node.
    #
    # @see #children?
    def leaf?
      !children?
    end

    alias is_leaf? leaf? # @todo: Aliased for eventual replacement

    # @!attribute [r] parentage
    # An array of ancestors of this node in reversed order
    # (the first element is the immediate parent of this node).
    #
    # Returns +nil+ if this is a root node.
    #
    # @return [Array<Tree::TreeNode>] An array of ancestors of this node
    # @return [nil] if this is a root node.
    def parentage
      return nil if root?

      parentage_array = []
      prev_parent = parent
      while prev_parent
        parentage_array << prev_parent
        prev_parent = prev_parent.parent
      end
      parentage_array
    end

    # @!group Node Creation

    # Creates a new node with a name and optional content.
    # The node name is expected to be unique within the tree.
    #
    # The content can be of any type, and defaults to +nil+.
    #
    # @param [Object] name Name of the node. Conventional usage is to pass a
    #   String (Integer names may cause *surprises*)
    #
    # @param [Object] content Content of the node.
    #
    # @raise [ArgumentError] Raised if the node name is empty.
    #
    # @note If the name is an +Integer+, then the semantics of {#[]} access
    #   method can be surprising, as an +Integer+ parameter to that method
    #   normally acts as an index to the children array, and follows the
    #   _zero-based_ indexing convention.
    #
    # @see #[]
    def initialize(name, content = nil)
      raise ArgumentError, 'Node name HAS to be provided!' if name.nil?

      name = name.to_s if name.is_a?(Integer)
      @name = name
      @content = content

      @children_hash = {}
      @children = []
      set_as_root!
    end

    # Returns a copy of this node, with its parent and children links removed.
    # The original node remains attached to its tree.
    #
    # @return [Tree::TreeNode] A copy of this node.
    def detached_copy
      cloned_content =
        begin
          @content&.clone
        rescue TypeError
          @content
        end
      self.class.new(@name, cloned_content)
    end

    # Returns a copy of entire (sub-)tree from this node.
    #
    # @author Vincenzo Farruggia
    # @since 0.8.0
    #
    # @return [Tree::TreeNode] A copy of (sub-)tree from this node.
    def detached_subtree_copy
      new_node = detached_copy
      children { |child| new_node << child.detached_subtree_copy }
      new_node
    end

    # Alias for {Tree::TreeNode#detached_subtree_copy}
    #
    # @see Tree::TreeNode#detached_subtree_copy
    alias dup detached_subtree_copy

    # Returns a {marshal-dump}[http://ruby-doc.org/core-1.8.7/Marshal.html]
    # representation of the (sub)tree rooted at this node.
    #
    def marshal_dump
      collect(&:create_dump_rep)
    end

    # Creates a dump representation of this node and returns the same as
    # a hash.
    def create_dump_rep # :nodoc:
      { name: @name,
        parent: (root? ? nil : @parent.name),
        content: Marshal.dump(@content) }
    end

    protected :create_dump_rep

    # Loads a marshaled dump of a tree and returns the root node of the
    # reconstructed tree. See the
    # {Marshal}[http://ruby-doc.org/core-1.8.7/Marshal.html] class for
    # additional details.
    #
    # NOTE: This is a potentially *unsafe* method with similar concerns as with
    # the Marshal#load method, and should *not* be used with untrusted user
    # provided data.
    #
    # @todo This method probably should be a class method. It currently clobbers
    #       self and makes itself the root.
    #
    def marshal_load(dumped_tree_array)
      nodes = {}
      dumped_tree_array.each do |node_hash|
        name        = node_hash[:name]
        parent_name = node_hash[:parent]
        content     = Marshal.load(node_hash[:content])

        if parent_name
          nodes[name] = current_node = self.class.new(name, content)
          nodes[parent_name].add current_node
        else
          # This is the root node, hence initialize self.
          initialize(name, content)

          nodes[name] = self # Add self to the list of nodes
        end
      end
    end

    # @!endgroup

    # Returns string representation of this node.
    # This method is primarily meant for debugging purposes.
    #
    # @return [String] A string representation of the node.
    def to_s
      content_str = @content.nil? ? '<Empty>' : @content.to_s
      [
        "Node Name: #{@name} Content: #{content_str}",
        "Parent: #{root? ? '<None>' : @parent.name}",
        "Children: #{@children.length} Total Nodes: #{size}"
      ].join(' ')
    end

    # Returns the requested node from the set of immediate children.
    #
    # - If the +name+ argument is an _Integer_, then the in-sequence
    #   array of children is accessed using the argument as the
    #   *index* (zero-based).
    #
    # - If the +name+ argument is *NOT* an _Integer_, then it is taken to
    #   be the *name* of the child node to be returned.
    #
    # - To use an _Integer_ as the name, convert it to a _String_ first using
    #   +<integer>.to_s+.
    #
    # @param [String|Number] name_or_index Name of the child, or its
    #   positional index in the array of child nodes.
    #
    # @return [Tree::TreeNode] the requested child node.  If the index
    #   in not in range, or the name is not present, then a +nil+
    #   is returned.
    #
    # @raise [ArgumentError] Raised if the +name_or_index+ argument is +nil+.
    #
    # @see #add
    # @see #initialize
    def [](name_or_index)
      raise ArgumentError, 'Name_or_index needs to be provided!' if name_or_index.nil?

      case name_or_index
      in Integer
        @children[name_or_index]
      else
        @children_hash[name_or_index]
      end
    end

    # Provides a comparison operation for the nodes.
    #
    # Comparison is based on the natural ordering of the node name objects.
    #
    # @param [Tree::TreeNode] other The other node to compare against.
    #
    # @return [Integer] +1 if this node is a 'successor', 0 if equal and -1 if
    #                   this node is a 'predecessor'. Returns 'nil' if the other
    #                   object is not a 'Tree::TreeNode'.
    def <=>(other)
      return nil if other.nil? || !other.is_a?(Tree::TreeNode)

      name <=> other.name
    end
  end
end
