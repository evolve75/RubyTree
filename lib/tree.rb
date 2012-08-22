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

# Copyright (c) 2006, 2007, 2008, 2009, 2010, 2011, 2012 Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
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

require 'tree/tree_deps'
require 'tree/version'

# This module provides a TreeNode class which is the primary class for representing
# nodes in the tree.
#
# This module also acts as the namespace for all classes in the RubyTree package.
module Tree

  # == TreeNode Class Description
  #
  # This class models the nodes for an *N-ary* tree data structue. The
  # nodes are *named* and have a place-holder for the node data (i.e.,
  # _content_ of the node). The node names are required to be *unique*
  # within the tree (as the name is implicitly used as an _ID_ within
  # the data structure).
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
  #
  # == Example
  #
  # The following example implements this tree structure:
  #
  #                    +------------+
  #                    |    ROOT    |
  #                    +-----+------+
  #            +-------------+------------+
  #            |                          |
  #    +-------+-------+          +-------+-------+
  #    |  CHILD 1      |          |  CHILD 2      |
  #    +-------+-------+          +---------------+
  #            |
  #            |
  #    +-------+-------+
  #    | GRANDCHILD 1  |
  #    +---------------+
  #
  #    # ..... Example starts.
  #    require 'tree'                 # Load the library
  #
  #    # ..... Create the root node first.  Note that every node has a name and an optional content payload.
  #    root_node = Tree::TreeNode.new("ROOT", "Root Content")
  #    root_node.print_tree
  #
  #    # ..... Now insert the child nodes.  Note that you can "chain" the child insertions for a given path to any depth.
  #    root_node << Tree::TreeNode.new("CHILD1", "Child1 Content") << Tree::TreeNode.new("GRANDCHILD1", "GrandChild1 Content")
  #    root_node << Tree::TreeNode.new("CHILD2", "Child2 Content")
  #
  #    # ..... Lets print the representation to stdout.  This is primarily used for debugging purposes.
  #    root_node.print_tree
  #
  #    # ..... Lets directly access children and grandchildren of the root.  The can be "chained" for a given path to any depth.
  #    child1       = root_node["CHILD1"]
  #    grand_child1 = root_node["CHILD1"]["GRANDCHILD1"]
  #
  #    # ..... Now lets retrieve siblings of the current node as an array.
  #    siblings_of_child1 = child1.siblings
  #
  #    # ..... Lets retrieve immediate children of the root node as an array.
  #    children_of_root = root_node.children
  #
  #    # ..... This is a depth-first and L-to-R pre-ordered traversal.
  #    root_node.each { |node| node.content.reverse }
  #
  #    # ..... Lets remove a child node from the root node.
  #    root_node.remove!(child1)
  #
  # @author Anupam Sengupta
  class TreeNode
    include Enumerable

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
    # @see content
    attr_reader   :name

    # @!attribute [rw] content
    #
    # Content of this node.  Can be +nil+.  Note that there is no
    # uniqueness constraint related to this attribute.
    #
    # @see name
    attr_accessor :content

    # @!attribute [r] parent
    #
    # Parent of this node.  Will be +nil+ for a root node.
    attr_reader   :parent

    # @!group Node Creation

    # Creates a new node with a name and optional content.
    # The node name is expected to be unique within the tree.
    #
    # The content can be of any type, and defaults to +nil+.
    #
    # @param [Object] name Name of the node.  Conventional usage is to pass a String
    #   (Integer names may cause *surprises*)
    # @param [Object] content Content of the node.
    #
    # @raise [ArgumentError] Raised if the node name is empty.
    #
    # @note If the name is an +Integer+, then the semantics of +TreeNode[]+ can
    #   be surprising, as an +Integer+ parameter to that method normally acts
    #   as an index to the <em>children array</em>, and follows the
    #   <em>zero-based</em> indexing convention.
    #
    # @see #[]
    def initialize(name, content = nil)
      raise ArgumentError, "Node name HAS to be provided!" if name == nil
      @name, @content = name, content

      if name.kind_of?(Integer)
        warn StandardWarning,
             "Using integer as node name. Semantics of TreeNode[] may not be what you expect! #{name} #{content}"
      end

      self.set_as_root!
      @children_hash = Hash.new
      @children = []
    end

    # Returns a copy of the receiver node, with its parent and children links removed.
    # The original node remains attached to its tree.
    #
    # @return [Tree::TreeNode] A copy of the receiver node.
    def detached_copy
      Tree::TreeNode.new(@name, @content ? @content.clone : nil)
    end

    # Returns a copy of entire (sub-)tree from receiver node.
    #
    # @author Vincenzo Farruggia
    # @since 0.8.0
    #
    # @return [Tree::TreeNode] A copy of (sub-)tree from receiver node.
    def detached_subtree_copy
      new_node = detached_copy
      children { |child| new_node << child.detached_subtree_copy }
      new_node
    end

    # Alias for {Tree::TreeNode#detached_subtree_copy}
    #
    # @see Tree::TreeNode#detached_subtree_copy
    alias :dup :detached_subtree_copy

    # @!endgroup

    # Returns string representation of the receiver node.
    # This method is primarily meant for debugging purposes.
    #
    # @return [String] A string representation of the node.
    def to_s
      "Node Name: #{@name}" +
        " Content: " + (@content.to_s || "<Empty>") +
        " Parent: " + (is_root?()  ? "<None>" : @parent.name.to_s) +
        " Children: #{@children.length}" +
        " Total Nodes: #{size()}"
    end

    # @!attribute [r] parentage
    # An array of ancestors of the receiver node in reversed order
    # (the first element is the immediate parent of the receiver).
    #
    # Returns +nil+ if the receiver is a root node.
    #
    # @return [Array, nil] An array of ancestors of the receiver node, or +nil+ if this is a root node.
    def parentage
      return nil if is_root?

      parentage_array = []
      prev_parent = self.parent
      while (prev_parent)
        parentage_array << prev_parent
        prev_parent = prev_parent.parent
      end

      parentage_array
    end

    # Protected method to set the parent node for the receiver node.
    # This method should *NOT* be invoked by client code.
    #
    # @param [Tree::TreeNode] parent The parent node.
    #
    # @return [Tree::TreeNode] The parent node.
    def parent=(parent)         # :nodoc:
      @parent = parent
    end

    # @!group Structure Modification

    # Convenience synonym for {Tree::TreeNode#add} method.
    #
    # This method allows an easy mechanism to add node hierarchies to the tree
    # on a given path via chaining the method calls to successive child nodes.
    #
    # @example Add a child and grand-child to the root
    #   root << child << grand_child
    #
    # @param [Tree::TreeNode] child the child node to add.
    #
    # @return [Tree::TreeNode] The added child node.
    #
    # @see Tree::TreeNode#add
    def <<(child)
      add(child)
    end

    # Adds the specified child node to the receiver node.
    #
    # This method can also be used for *grafting* a subtree into the receiver node's tree, if the specified child node
    # is the root of a subtree (i.e., has child nodes under it).
    #
    # The receiver node becomes parent of the node passed in as the argument, and
    # the child is added as the last child ("right most") in the current set of
    # children of the receiver node.
    #
    # Additionally you can specify a insert position. The new node will be inserted
    # BEFORE that position. If you don't specify any position the node will be
    # just appended. This feature is provided to make implementation of node
    # movement within the tree very simple.
    #
    # If an insertion position is provided, it needs to be within the valid range of:
    #
    #    -children.size..children.size
    #
    # This is to prevent +nil+ nodes being created as children if a non-existant position is used.
    #
    # @param [Tree::TreeNode] child The child node to add.
    # @param [optional, Number] at_index The optional position where the node is to be inserted.
    #
    # @return [Tree::TreeNode] The added child node.
    #
    # @raise [RuntimeError] This exception is raised if another child node with the same
    # name exists, or if an invalid insertion position is specified.
    # @raise [ArgumentError] This exception is raised if a +nil+ node is passed as the argument.
    #
    # @see #<<
    def add(child, at_index = -1)
      raise ArgumentError, "Attempting to add a nil node" unless child # Only handles the immediate child scenario
      raise ArgumentError, "Attempting add node to itself" if self == child
      raise "Child #{child.name} already added!" if @children_hash.has_key?(child.name)

      if insertion_range.include?(at_index)
        @children.insert(at_index, child)
      else
        raise "Attempting to insert a child at a non-existent location (#{at_index}) when only positions from #{insertion_range.min} to #{insertion_range.max} exist."
      end

      @children_hash[child.name]  = child
      child.parent = self
      return child
    end

    # Removes the specified child node from the receiver node.
    #
    # This method can also be used for *pruning* a sub-tree, in cases where the removed child node is
    # the root of the sub-tree to be pruned.
    #
    # The removed child node is orphaned but accessible if an alternate reference exists.  If accessible via
    # an alternate reference, the removed child will report itself as a root node for its sub-tree.
    #
    # @param [Tree::TreeNode] child The child node to remove.
    #
    # @return [Tree::TreeNode] The removed child node, or +nil+ if a +nil+ was passed in as argument.
    #
    # @see #remove_from_parent!
    # @see #remove_all!
    def remove!(child)
      return nil unless child

      @children_hash.delete(child.name)
      @children.delete(child)
      child.set_as_root!
      child
    end

    # Removes the receiver node from its parent.  The reciever node becomes the new root for its subtree.
    #
    # If this is the root node, then does nothing.
    #
    # @return [Tree:TreeNode] +self+ (the removed receiver node) if the operation is successful, +nil+ otherwise.
    #
    # @see #remove_all!
    def remove_from_parent!
      @parent.remove!(self) unless is_root?
    end

    # Removes all children from the receiver node.  If an indepedent reference exists to the child
    # nodes, then these child nodes report themselves as roots after this operation.
    #
    # @return [Tree::TreeNode] The receiver node (+self+)
    #
    # @see #remove!
    # @see #remove_from_parent!
    def remove_all!
      @children.each { |child| child.set_as_root! }

      @children_hash.clear
      @children.clear
      self
    end

    # Returns +true+ if the receiver node has content.
    #
    # @return [Boolean] +true+ if the node has content.
    def has_content?
      @content != nil
    end

    # Protected method which sets the receiver node as a root node.
    #
    # @return +nil+.
    def set_as_root!              # :nodoc:
      @parent = nil
    end

    # @!endgroup

    # Returns +true+ if the receiver is a root node.  Note that
    # orphaned children will also be reported as root nodes.
    #
    # @return [Boolean] +true+ if this is a root node.
    def is_root?
      @parent == nil
    end

    # Returns +true+ if the receiver node has any child node.
    #
    # @return [Boolean] +true+ if child nodes exist.
    #
    # @see #is_leaf?
    def has_children?
      @children.length != 0
    end

    # Returns +true+ if the receiver node is a 'leaf' - i.e., one without
    # any children.
    #
    # @return [Boolean] +true+ if this is a leaf node.
    #
    # @see #has_children?
    def is_leaf?
      !has_children?
    end

    # @!attribute [rw] children
    # An array of all the immediate children of the receiver
    # node.  The child nodes are ordered "left-to-right" in the
    # returned array.
    #
    # If a block is given, yields each child node to the block
    # traversing from left to right.
    #
    # @yield [child] Each child is passed to the block, if given
    # @yieldparam [Tree::TreeNode] child Each child node.
    #
    # @return [Array<Tree::TreeNode>] An array of the child nodes, if no block is given.
    def children
      if block_given?
        @children.each {|child| yield child}
      else
        @children
      end
    end

    # @!attribute [rw] first_child
    # First child of the receiver node.
    # Will be +nil+ if no children are present.
    #
    # @return [Tree::TreeNode] The first child, or +nil+ if none is present.
    def first_child
      children.first
    end

    # @!attribute [rw] last_child
    # Last child of the receiver node.
    # Will be +nil+ if no children are present.
    #
    # @return [Tree::TreeNode] The last child, or +nil+ if none is present.
    def last_child
      children.last
    end

    # @!group Tree Traversal

    # Traverses each node (including the receiver node) of the (sub)tree rooted at this node
    # by yielding the nodes to the specified block.
    #
    # The traversal is *depth-first* and from *left-to-right* in pre-ordered sequence.
    #
    # @yield [child] Each node is passed to the block.
    # @yieldparam [Tree::TreeNode] child Each node.
    #
    # @see #preordered_each
    # @see #breadth_each
    def each(&block)             # :yields: node
      yield self
      children { |child| child.each(&block) }
    end

    # Traverses the (sub)tree rooted at the receiver node in pre-ordered sequence.
    # This is a synonym of {Tree::TreeNode#each}.
    #
    # @yield [child] Each child is passed to the block.
    # @yieldparam [Tree::TreeNode] node Each node.
    #
    # @see #each
    # @see #breadth_each
    def preordered_each(&block)  # :yields: node
      each(&block)
    end

    # Performs breadth-first traversal of the (sub)tree rooted at the receiver node. The
    # traversal at a given level is from *left-to-right*.  The receiver node itself is the first
    # node to be traversed.
    #
    # @yield [child] Each node is passed to the block.
    # @yieldparam [Tree::TreeNode] node Each node.
    #
    # @see #preordered_each
    # @see #breadth_each
    def breadth_each(&block)
      node_queue = [self]       # Create a queue with self as the initial entry

      # Use a queue to do breadth traversal
      until node_queue.empty?
        node_to_traverse = node_queue.shift
        yield node_to_traverse
        # Enqueue the children from left to right.
        node_to_traverse.children { |child| node_queue.push child }
      end
    end

    # Yields every leaf node of the (sub)tree rooted at the receiver node to the specified block.
    #
    # May yield this node as well if this is a leaf node.
    # Leaf traversal is *depth-first* and *left-to-right*.
    #
    # @yield [node] Each leaf node is passed to the block.
    # @yieldparam [Tree::TreeNode] node Each leaf node.
    #
    # @see #each
    # @see #breadth_each
    def each_leaf &block
      if block_given?
        self.each { |node| yield(node) if node.is_leaf? }
      else
        self.select { |node| node.is_leaf?}
      end
    end

    # Returns the requested node from the set of immediate children.
    #
    # - If the +name+ argument is an _Integer_, then the in-sequence
    #   array of children is accessed using the argument as the
    #   *index* (zero-based).  However, if the second _optional_
    #   +num_as_name+ argument is +true+, then the +name+ is used
    #   literally as a name, and *NOT* as an *index*
    #
    # - If the +name+ argument is *NOT* an _Integer_, then it is taken to
    #   be the *name* of the child node to be returned.
    #
    # If a non-+Integer+ +name+ is passed, and the +num_as_name+
    # parameter is also +true+, then a warning is thrown (as this is a
    # redundant use of the +num_as_name+ flag.)
    #
    # @param [String|Number] name_or_index Name of the child, or its
    #   positional index in the array of child nodes.
    #
    # @param [Boolean] num_as_name Whether to treat the +Integer+
    #   +name+ argument as an actual name, and *NOT* as an _index_ to
    #   the children array.
    #
    # @return [Tree::TreeNode] the requested child node.  If the index
    #   in not in range, or the name is not present, then a +nil+
    #   is returned.
    #
    # @note The use of +Integer+ names is allowed by using the optional +num_as_name+ flag.
    #
    # @raise [ArgumentError] Raised if the +name_or_index+ argument is +nil+.
    #
    # @see #add
    # @see #initialize
    def [](name_or_index, num_as_name=false)
      raise ArgumentError, "Name_or_index needs to be provided!" if name_or_index == nil

      if name_or_index.kind_of?(Integer) and not num_as_name
        @children[name_or_index]
      else
        if num_as_name and not name_or_index.kind_of?(Integer)
          warn StandardWarning, "Redundant use of the `num_as_name` flag for non-integer node name"
        end
        @children_hash[name_or_index]
      end
    end

    # @!endgroup

    # @!attribute [r] size
    # Total number of nodes in this (sub)tree, including the receiver node.
    #
    # Size of the tree is defined as:
    #
    # Size:: Total number nodes in the subtree including the receiver node.
    #
    # @return [Integer] Total number of nodes in this (sub)tree.
    def size
      @children.inject(1) {|sum, node| sum + node.size}
    end

    # Convenience synonym for {Tree::TreeNode#size}.
    #
    # @deprecated This method name is ambiguous and may be removed.  Use TreeNode#size instead.
    #
    # @return [Integer] The total number of nodes in this (sub)tree.
    # @see #size
    def length
      size()
    end

    # Pretty prints the (sub)tree rooted at the receiver node.
    #
    # @param [Integer] level The indentation level (4 spaces) to start with.
    def print_tree(level = 0)
      if is_root?
        print "*"
      else
        print "|" unless parent.is_last_sibling?
        print(' ' * (level - 1) * 4)
        print(is_last_sibling? ? "+" : "|")
        print "---"
        print(has_children? ? "+" : ">")
      end

      puts " #{name}"

      children { |child| child.print_tree(level + 1)}
    end

    # @!attribute [rw] root
    # root node for the (sub)tree to which the receiver node belongs.
    # A root node's root is itself.
    #
    # @return [Tree::TreeNode] Root of the (sub)tree.
    def root
      root = self
      root = root.parent while !root.is_root?
      root
    end

    # @!attribute [rw] first_sibling
    # First sibling of the receiver node. If this is the root node, then returns
    # itself.
    #
    # 'First' sibling is defined as follows:
    # First sibling:: The left-most child of the receiver's parent, which may be the receiver itself
    #
    # @return [Tree::TreeNode] The first sibling node.
    #
    # @see #is_first_sibling?
    # @see #last_sibling
    def first_sibling
      is_root? ? self : parent.children.first
    end

    # Returns +true+ if the receiver node is the first sibling at its level.
    #
    # @return [Boolean] +true+ if this is the first sibling.
    #
    # @see #is_last_sibling?
    # @see #first_sibling
    def is_first_sibling?
      first_sibling == self
    end

    # @!attribute [rw] last_sibling
    # Last sibling of the receiver node.  If this is the root node, then returns
    # itself.
    #
    # 'Last' sibling is defined as follows:
    # Last sibling:: The right-most child of the receiver's parent, which may be the receiver itself
    #
    # @return [Tree::TreeNode] The last sibling node.
    #
    # @see #is_last_sibling?
    # @see #first_sibling
    def last_sibling
      is_root? ? self : parent.children.last
    end

    # Returns +true+ if the receiver node is the last sibling at its level.
    #
    # @return [Boolean] +true+ if this is the last sibling.
    #
    # @see #is_first_sibling?
    # @see #last_sibling
    def is_last_sibling?
      last_sibling == self
    end

    # @!attribute [rw] siblings
    # An array of siblings for the receiver node.  The receiver node is excluded.
    #
    # If a block is provided, yields each of the sibling nodes to the block.
    # The root always has +nil+ siblings.
    #
    # @yield [sibling] Each sibling is passed to the block.
    # @yieldparam [Tree::TreeNode] sibling Each sibling node.
    #
    # @return [Array<Tree::TreeNode>] Array of siblings of this node.
    #
    # @see #first_sibling
    # @see #last_sibling
    def siblings
      return [] if is_root?

      if block_given?
        parent.children.each { |sibling| yield sibling if sibling != self }
      else
        siblings = []
        parent.children {|my_sibling| siblings << my_sibling if my_sibling != self}
        siblings
      end
    end

    # Returns +true+ if the receiver node is the only child of its parent.
    #
    # As a special case, a root node will always return +true+.
    #
    # @return [Boolean] +true+ if this is the only child of its parent.
    #
    # @see #siblings
    def is_only_child?
      is_root? ? true : parent.children.size == 1
    end

    # @!attribute [rw] next_sibling
    # Next sibling for the receiver node.
    # The 'next' node is defined as the node to right of the receiver node.
    #
    # Will return +nil+ if no subsequent node is present, or if the receiver is a root node.
    #
    # @return [Tree::treeNode] the next sibling node, if present.
    #
    # @see #previous_sibling
    # @see #siblings
    def next_sibling
      return nil if is_root?

      myidx = parent.children.index(self)
      parent.children.at(myidx + 1) if myidx
    end

    # @!attribute [rw] previous_sibling
    # Previous sibling of the receiver node.
    # 'Previous' node is defined to be the node to left of the receiver node.
    #
    # Will return +nil+ if no predecessor node is present, or if the receiver is a root node.
    #
    # @return [Tree::treeNode] the previous sibling node, if present.
    #
    # @see #next_sibling
    # @see #siblings
    def previous_sibling
      return nil if is_root?

      myidx = parent.children.index(self)
      parent.children.at(myidx - 1) if myidx && myidx > 0
    end

    # Provides a comparision operation for the nodes.
    #
    # Comparision is based on the natural character-set ordering of the node name.
    #
    # @param [Tree::TreeNode] other The other node to compare against.
    #
    # @return [Integer] +1 if this node is a 'successor', 0 if equal and -1 if this node is a 'predecessor'.
    def <=>(other)
      return +1 if other == nil
      self.name <=> other.name
    end

    # Freezes all nodes in the (sub)tree rooted at the receiver node.
    #
    # The nodes become immutable after this operation.  In effect, the entire tree's
    # structure and contents become _read-only_ and cannot be changed.
    def freeze_tree!
      each {|node| node.freeze}
    end

    # Returns a marshal-dump represention of the (sub)tree rooted at the receiver node.
    def marshal_dump
      self.collect { |node| node.create_dump_rep }
    end

    # Creates a dump representation of the reciever node and returns the same as a hash.
    def create_dump_rep           # :nodoc:
      { :name => @name, :parent => (is_root? ? nil : @parent.name),  :content => Marshal.dump(@content)}
    end

    # Loads a marshalled dump of a tree and returns the root node of the
    # reconstructed tree. See the Marshal class for additional details.
    #
    #
    # @todo This method probably should be a class method.  It currently clobbers self
    #       and makes itself the root.
    #
    def marshal_load(dumped_tree_array)
      nodes = { }
      dumped_tree_array.each do |node_hash|
        name        = node_hash[:name]
        parent_name = node_hash[:parent]
        content     = Marshal.load(node_hash[:content])

        if parent_name then
          nodes[name] = current_node = Tree::TreeNode.new(name, content)
          nodes[parent_name].add current_node
        else
          # This is the root node, hence initialize self.
          initialize(name, content)

          nodes[name] = self    # Add self to the list of nodes
        end
      end
    end

    # Creates a JSON ready Hash for the #to_json method.
    #
    # @author Eric Cline (https://github.com/escline)
    # @since 0.8.3
    #
    # @return A hash based representation of the JSON
    #
    # Rails uses JSON in ActiveSupport, and all Rails JSON encoding goes through as_json
    #
    # @see Tree::TreeNode.to_json
    # @see http://stackoverflow.com/a/6880638/273808
    def as_json(options = {})

        json_hash = {
          "name"         => name,
          "content"      => content,
          JSON.create_id => self.class.name
        }

        if has_children?
          json_hash["children"] = children
        end

        return json_hash

    end

    # Creates a JSON representation of this node including all it's children.   This requires the JSON gem to be
    # available, or else the operation fails with a warning message.
    # Uses the Hash output of as_json method, defined above.
    #
    # @author Dirk Breuer (http://github.com/railsbros-dirk)
    # @since 0.7.0
    #
    # @return The JSON representation of this subtree.
    #
    # @see Tree::TreeNode.json_create
    # @see Tree::TreeNode.as_json
    # @see http://flori.github.com/json
    def to_json(*a)
      as_json.to_json(*a)
    end

    # Helper method to create a Tree::TreeNode instance from the JSON hash representation.  Note that this method should
    # *NOT* be called directly.  Instead, to convert the JSON hash back to a tree, do:
    #
    # tree = JSON.parse (the_json_hash)
    #
    # This operation requires the JSON gem to be available, or else the operation fails with a warning message.
    #
    # @author Dirk Breuer (http://github.com/railsbros-dirk)
    # @since 0.7.0
    #
    # @param [Hash] json_hash The JSON hash to convert from.
    #
    # @return [Tree::TreeNode] The created tree.
    #
    # @see #to_json
    # @see http://flori.github.com/json
    def self.json_create(json_hash)

      node = new(json_hash["name"], json_hash["content"])

      json_hash["children"].each do |child|
        node << child
      end if json_hash["children"]

      return node

    end

    # @!attribute [r] node_height
    # Height of the (sub)tree from the receiver node.  Height of a node is defined as:
    #
    # Height:: Length of the longest downward path to a leaf from the node.
    #
    # - Height from a root node is height of the entire tree.
    # - The height of a leaf node is zero.
    #
    # @return [Integer] Height of the node.
    def node_height
      return 0 if is_leaf?
      1 + @children.collect { |child| child.node_height }.max
    end

    # @!attribute [r] node_depth
    # Depth of the receiver node in its tree.  Depth of a node is defined as:
    #
    # Depth:: Length of the node's path to its root.  Depth of a root node is zero.
    #
    # *Note* that the deprecated method Tree::TreeNode#depth was incorrectly computing this value.
    # Please replace all calls to the old method with Tree::TreeNode#node_depth instead.
    #
    # 'level' is an alias for this method.
    #
    # @return [Integer] Depth of this node.
    def node_depth
      return 0 if is_root?
      1 + parent.node_depth
    end

    alias level node_depth       # Aliased level() method to the node_depth().

    # Returns depth of the tree from the receiver node. A single leaf node has a depth of 1.
    #
    # This method is *DEPRECATED* and may be removed in the subsequent releases.
    # Note that the value returned by this method is actually the:
    #
    # _height_ + 1 of the node, *NOT* the _depth_.
    #
    # For correct and conventional behavior, please use {Tree::TreeNode#node_depth} and
    # {Tree::TreeNode#node_height} methods instead.
    #
    # @return [Integer] depth of the node.
    # @deprecated This method returns an incorrect value.  Use the 'node_depth' method instead.
    #
    # @see #node_depth
    def depth
      warn DeprecatedMethodWarning, 'This method is deprecated.  Please use node_depth() or node_height() instead (bug # 22535)'

      return 1 if is_leaf?
      1 + @children.collect { |child| child.depth }.max
    end

    # Allow the deprecated CamelCase method names.  Display a warning.
    # :nodoc:
    def method_missing(meth, *args, &blk)
      if self.respond_to?(new_method_name = underscore(meth))
        warn DeprecatedMethodWarning, "The camelCased methods are deprecated. Please use #{new_method_name} instead of #{meth}"
        return send(new_method_name, *args, &blk)
      else
        super
      end
    end

    # @!attribute [r] breadth
    # Breadth of the tree at the receiver node's level.
    # A single node without siblings has a breadth of 1.
    #
    # Breadth is defined to be:
    # Breadth:: Number of sibling nodes to this node + 1 (this node itself),
    # i.e., the number of children the parent of this node has.
    #
    # @return [Integer] breadth of the node's level.
    def breadth
      is_root? ? 1 : parent.children.size
    end

    # @!attribute [r] in_degree
    # The incoming edge-count of the receiver node.
    #
    # In-degree is defined as:
    # In-degree:: Number of edges arriving at the node (0 for root, 1 for all other nodes)
    #
    # - In-degree = 0 for a root or orphaned node
    # - In-degree = 1 for a node which has a parent
    #
    # @return [Integer] The in-degree of this node.
    def in_degree
      is_root? ? 0 : 1
    end

    # @!attribute [r] out_degree
    # The outgoing edge-count of the receiver node.
    #
    # Out-degree is defined as:
    # Out-degree:: Number of edges leaving the node (zero for leafs)
    #
    # @return [Integer] The out-degree of this node.
    def out_degree
      is_leaf? ? 0 : children.size
    end

    protected :parent=, :set_as_root!, :create_dump_rep

    private

    # Convert a CamelCasedWord to a underscore separated camel_cased_word.
    #
    # Just copied from ActiveSupport::Inflector because it is only needed
    # aliasing deprecated methods
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    # Return a range of valid insertion positions.  Used in the #add method.
    def insertion_range
      max = @children.size
      min = -(max+1)
      min..max
    end

  end
end
